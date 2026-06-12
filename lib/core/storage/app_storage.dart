import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Assidim/core/models/user_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Chiavi centralizzate
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Key {
  // SecureStorage
  static const username = 'username';
  static const password = 'password';
  static const userId = 'user_id';
  static const email = 'email';
  static const nome = 'nome';
  static const cognome = 'cognome';
  static const playerId = 'playerid';
  static const jwtToken = 'jwt_token';

  // SharedPreferences
  static const isLoggedIn = 'isAlreadyLogged';
  static const biometricsPermission = 'hasGivenPermissionToUseBiometrics';
  static const biometricsUsed = 'alreadyLoggedInWithBiometrics';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Credentials DTO
// ─────────────────────────────────────────────────────────────────────────────

class StoredCredentials {
  final String username;
  final String password;
  const StoredCredentials({required this.username, required this.password});
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppStorage
// ─────────────────────────────────────────────────────────────────────────────

/// Wrapper unico per SharedPreferences + FlutterSecureStorage.
/// Centralizza tutte le operazioni di persistenza, eliminando la
/// duplicazione sparsa nei vari widget.
class AppStorage {
  final FlutterSecureStorage _secure;

  AppStorage({FlutterSecureStorage? secure})
      : _secure = secure ?? const FlutterSecureStorage();

  // ─── Login flag ───────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_Key.isLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Key.isLoggedIn, value);
  }

  // ─── Credenziali ──────────────────────────────────────────────────────────

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _secure.write(key: _Key.username, value: username);
    await _secure.write(key: _Key.password, value: password);
  }

  Future<StoredCredentials?> getCredentials() async {
    final username = await _secure.read(key: _Key.username);
    final password = await _secure.read(key: _Key.password);
    if (username == null || username.isEmpty ||
        password == null || password.isEmpty) return null;
    return StoredCredentials(username: username, password: password);
  }

  // ─── Dati utente ──────────────────────────────────────────────────────────

  Future<void> saveUserData(UserData user, {String? playerId}) async {
    await _secure.write(key: _Key.userId, value: user.id);
    await _secure.write(key: _Key.email, value: user.email);
    await _secure.write(key: _Key.nome, value: user.nome);
    await _secure.write(key: _Key.cognome, value: user.cognome);
    if (playerId != null && playerId.isNotEmpty) {
      await _secure.write(key: _Key.playerId, value: playerId);
    }

    // Salva anche username nelle prefs per accesso rapido (non sensibile)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Key.username, user.username);
  }

  Future<String?> readUsername() => _secure.read(key: _Key.username);
  Future<String?> readPlayerId() => _secure.read(key: _Key.playerId);

  // ─── JWT token ────────────────────────────────────────────────────────────

  Future<void> saveJwtToken(String token) =>
      _secure.write(key: _Key.jwtToken, value: token);

  Future<String?> getJwtToken() => _secure.read(key: _Key.jwtToken);

  Future<void> clearJwtToken() => _secure.delete(key: _Key.jwtToken);

  // ─── Biometria ────────────────────────────────────────────────────────────

  Future<bool?> getBiometricsPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_Key.biometricsPermission)) return null;
    return prefs.getBool(_Key.biometricsPermission);
  }

  Future<void> setBiometricsPermission(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Key.biometricsPermission, value);
  }

  Future<bool> hasBiometricsBeenUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_Key.biometricsUsed);
  }

  Future<void> setBiometricsUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Key.biometricsUsed, true);
  }

  // ─── Logout / clear ───────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _secure.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
