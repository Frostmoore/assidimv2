import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/services/api_service.dart';
import 'package:Assidim/core/storage/app_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Result types
// ─────────────────────────────────────────────────────────────────────────────

enum AuthFailureReason {
  invalidCredentials,
  inactiveUser,
  wrongAgencyCode,
  userAlreadyExists,
  network,
  unknown,
}

class AuthResult {
  final bool success;
  final UserData? user;
  final AuthFailureReason? failureReason;
  final String? rawResponseCode;
  final String? errorMessage;

  const AuthResult._({
    required this.success,
    this.user,
    this.failureReason,
    this.rawResponseCode,
    this.errorMessage,
  });

  factory AuthResult.ok(UserData user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.notLoggedIn() => AuthResult._(
      success: false,
      failureReason: AuthFailureReason.invalidCredentials);

  factory AuthResult.failure(String code, {String? message}) {
    final reason = switch (code) {
      '97' => AuthFailureReason.inactiveUser,
      '98' => AuthFailureReason.invalidCredentials,
      '3' => AuthFailureReason.userAlreadyExists,
      '4' => AuthFailureReason.wrongAgencyCode,
      _ => AuthFailureReason.unknown,
    };
    return AuthResult._(
      success: false,
      failureReason: reason,
      rawResponseCode: code,
      errorMessage: message,
    );
  }

  factory AuthResult.networkError(String message) => AuthResult._(
      success: false,
      failureReason: AuthFailureReason.network,
      errorMessage: message);
}

enum RegisterFailureReason {
  userAlreadyExists,
  wrongAgencyCode,
  network,
  unknown
}

class RegisterResult {
  final bool success;
  final RegisterFailureReason? failureReason;
  final String? rawResponseCode;

  const RegisterResult._({
    required this.success,
    this.failureReason,
    this.rawResponseCode,
  });

  factory RegisterResult.ok() => const RegisterResult._(success: true);

  factory RegisterResult.failure(String code) {
    final reason = switch (code) {
      '3' => RegisterFailureReason.userAlreadyExists,
      '4' => RegisterFailureReason.wrongAgencyCode,
      _ => RegisterFailureReason.unknown,
    };
    return RegisterResult._(
        success: false, failureReason: reason, rawResponseCode: code);
  }

  factory RegisterResult.networkError() =>
      const RegisterResult._(
          success: false, failureReason: RegisterFailureReason.network);
}

// ─────────────────────────────────────────────────────────────────────────────
//  AuthService
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  final ApiService _api;
  final AppStorage _storage;

  const AuthService(this._api, this._storage);

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String username, String password) async {
    try {
      final url = constants.apiUri(constants.ENDPOINT_V2_LOGIN);
      final data = await _api.postJsonV2(url, body: {
        'agency_id': constants.ID,
        'username': username,
        'password': password,
      });

      final token = data['token']?.toString() ?? '';
      final refreshToken = data['refresh_token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap == null) return AuthResult.failure('100');

      _api.setToken(token);
      await _storage.saveJwtToken(token);
      // Auto-login senza salvare la password: si conserva il refresh token.
      if (refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }

      final user = UserData.fromJson(userMap);
      await _storage.saveUsername(user.username);
      await _storage.saveUserData(user);
      await _storage.setLoggedIn(true);

      await _syncOneSignal(user.playerId ?? '${user.username}_login');

      return AuthResult.ok(user);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.code == 'invalid_credentials') {
        return AuthResult.failure('98');
      }
      if (e.statusCode == 403 || e.code == 'inactive_user') {
        return AuthResult.failure('97');
      }
      return AuthResult.networkError(e.message);
    }
  }

  // ─── Auto-login ───────────────────────────────────────────────────────────

  Future<AuthResult> autoLogin() async {
    // 1) Prova il JWT salvato
    final jwt = await _storage.getJwtToken();
    if (jwt != null && jwt.isNotEmpty) {
      _api.setToken(jwt);
      try {
        return AuthResult.ok(await _fetchMe());
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          _api.clearToken();
          await _storage.clearJwtToken();
          // JWT scaduto → prosegue col refresh token
        } else {
          return AuthResult.networkError(e.message);
        }
      }
    }

    // 2) JWT assente/scaduto → scambia il refresh token per un nuovo JWT
    final loggedIn = await _storage.isLoggedIn();
    if (!loggedIn) return AuthResult.notLoggedIn();

    if (!await refresh()) return AuthResult.notLoggedIn();

    // 3) Con il nuovo JWT recupera l'utente
    try {
      return AuthResult.ok(await _fetchMe());
    } on ApiException catch (e) {
      return AuthResult.networkError(e.message);
    }
  }

  /// Scambia il refresh token salvato con un nuovo JWT (rotazione lato server).
  /// Ritorna true se il rinnovo riesce; in caso contrario pulisce il refresh
  /// token (serve un login manuale).
  Future<bool> refresh() async {
    final stored = await _storage.getRefreshToken();
    if (stored == null || stored.isEmpty) return false;

    try {
      final data = await _api.postJsonV2(
        constants.apiUri(constants.ENDPOINT_V2_REFRESH),
        body: {'refresh_token': stored},
      );
      final token = data['token']?.toString() ?? '';
      final newRefresh = data['refresh_token']?.toString() ?? '';
      if (token.isEmpty) return false;

      _api.setToken(token);
      await _storage.saveJwtToken(token);
      if (newRefresh.isNotEmpty) {
        await _storage.saveRefreshToken(newRefresh);
      }
      return true;
    } on ApiException {
      await _storage.clearRefreshToken();
      return false;
    }
  }

  Future<UserData> _fetchMe() async {
    final data = await _api.getV2(constants.apiUri(constants.ENDPOINT_V2_ME));
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    return UserData.fromJson(userMap);
  }

  // ─── Registrazione ────────────────────────────────────────────────────────

  Future<RegisterResult> register({
    required String username,
    required String password,
    required String nome,
    required String cognome,
    required String email,
    required String telefono,
    required String cf,
    required String? dataDiNascita,
    required bool privacy1,
    required bool privacy2,
    required bool privacy3,
    required bool privacy4,
  }) async {
    try {
      final url = constants.apiUri(constants.ENDPOINT_V2_REG);
      final playerId = '${username}_${DateTime.now().millisecondsSinceEpoch}';

      await _api.postJsonV2(url, body: {
        'agency_id': constants.ID,
        'username': username,
        'password': password,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'telefono': telefono,
        'cf': cf,
        'datadinascita': dataDiNascita,
        'privacy1': privacy1,
        'privacy2': privacy2,
        'privacy3': privacy3,
        'privacy4': privacy4,
        'playerid': playerId,
      });

      return RegisterResult.ok();
    } on ApiException catch (e) {
      if (e.statusCode == 409 || e.code == 'user_exists') {
        return RegisterResult.failure('3');
      }
      if (e.statusCode == 403 || e.code == 'invalid_agency') {
        return RegisterResult.failure('4');
      }
      return RegisterResult.networkError();
    }
  }

  // ─── Reset password ───────────────────────────────────────────────────────

  Future<bool> resetPassword(String usernameOrEmail) async {
    try {
      final url = constants.apiUri(constants.ENDPOINT_V2_PASS);
      await _api.postJsonV2(url, body: {
        'agency_id': constants.ID,
        'username': usernameOrEmail,
      });
      return true;
    } on ApiException {
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Revoca il refresh token lato server (best-effort, non bloccante)
    final stored = await _storage.getRefreshToken();
    if (stored != null && stored.isNotEmpty) {
      try {
        await _api.postJsonV2(
          constants.apiUri(constants.ENDPOINT_V2_LOGOUT),
          body: {'refresh_token': stored},
        );
      } catch (_) {}
    }

    try {
      await OneSignal.logout();
    } catch (_) {}
    _api.clearToken();
    await _storage.clearJwtToken();
    await _storage.clearAll();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _syncOneSignal(String externalUserId) async {
    try {
      await OneSignal.login(externalUserId);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final sub = OneSignal.User.pushSubscription;
      if (sub.token == null || sub.id == null || sub.optedIn == false) {
        debugPrint('[Auth] OneSignal non attivo, retry login');
        await OneSignal.logout();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await OneSignal.login(externalUserId);
      }
    } catch (e) {
      debugPrint('[Auth] OneSignal sync error: $e');
    }
  }
}
