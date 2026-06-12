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
      final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_LOGIN);
      final data = await _api.postJsonV2(url, body: {
        'agency_id': constants.ID,
        'username': username,
        'password': password,
      });

      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap == null) return AuthResult.failure('100');

      _api.setToken(token);
      await _storage.saveJwtToken(token);

      final user = UserData.fromJson(userMap);
      await _storage.saveCredentials(username: user.username, password: password);
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
    // Try JWT first
    final jwt = await _storage.getJwtToken();
    if (jwt != null && jwt.isNotEmpty) {
      _api.setToken(jwt);
      try {
        final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_ME);
        final data = await _api.getV2(url);
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        final user = UserData.fromJson(userMap);
        return AuthResult.ok(user);
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          _api.clearToken();
          await _storage.clearJwtToken();
          // Fall through to credentials
        } else {
          return AuthResult.networkError(e.message);
        }
      }
    }

    // Fallback: re-login with stored credentials
    final loggedIn = await _storage.isLoggedIn();
    if (!loggedIn) return AuthResult.notLoggedIn();

    final creds = await _storage.getCredentials();
    if (creds == null) return AuthResult.notLoggedIn();

    return login(creds.username, creds.password);
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
      final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_REG);
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
      final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_PASS);
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
