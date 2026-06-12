import 'package:flutter/foundation.dart';
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/services/api_service.dart';
import 'package:Assidim/core/services/auth_service.dart';
import 'package:Assidim/core/services/config_service.dart';
import 'package:Assidim/core/services/notifiche_service.dart';
import 'package:Assidim/core/services/polizze_service.dart';
import 'package:Assidim/core/storage/app_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AuthState — sostituisce il vecchio `userStatus` int globale
// ─────────────────────────────────────────────────────────────────────────────

enum AuthState {
  /// Non autenticato, mostra login / registrazione
  unauthenticated,
  /// Utente loggato
  authenticated,
  /// Sta mostrando il form di registrazione
  registering,
  /// Username già in uso
  userAlreadyExists,
  /// Codice agenzia errato
  wrongAgencyCode,
  /// Registrazione completata con successo
  registrationSuccess,
  /// Reset password inviato
  passwordReset,
  /// Account non ancora attivato
  inactiveUser,
  /// Credenziali errate
  loginFailed,
  /// L'utente ha richiesto il recupero password
  forgotPassword,
  /// Errore generico
  error,
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppProvider
// ─────────────────────────────────────────────────────────────────────────────

/// Stato globale dell'applicazione accessibile tramite `Provider`.
/// Sostituisce le variabili globali mutabili in constants.dart e il pattern
/// `logParent()` / `setState()` a cascata.
class AppProvider extends ChangeNotifier {
  final ApiService _api;
  final AppStorage _storage;
  late final AuthService _auth;
  late final ConfigService _configSvc;

  late final PolizzeService _polizzeSvc;
  late final NotificheService _notificheSvc;

  AppProvider({required ApiService api, required AppStorage storage})
      : _api = api,
        _storage = storage {
    _auth = AuthService(_api, _storage);
    _configSvc = ConfigService(_api);
    _polizzeSvc = PolizzeService(_api);
    _notificheSvc = NotificheService(_api);
  }

  PolizzeService get polizzeService => _polizzeSvc;
  NotificheService get notificheService => _notificheSvc;

  // ─── Stato config ─────────────────────────────────────────────────────────

  AppConfig? _config;
  bool _isLoadingConfig = true;
  String? _configError;

  AppConfig? get config => _config;
  bool get isLoadingConfig => _isLoadingConfig;
  String? get configError => _configError;
  bool get hasConfig => _config != null;

  // ─── Stato auth ───────────────────────────────────────────────────────────

  AuthState _authState = AuthState.unauthenticated;
  UserData? _currentUser;

  AuthState get authState => _authState;
  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  // ─── Trigger notifiche (per push OneSignal) ───────────────────────────────

  int _notificheTrigger = 0;
  int get notificheTrigger => _notificheTrigger;

  void triggerNotificheRefresh() {
    _notificheTrigger++;
    notifyListeners();
  }

  // ─── Inizializzazione ─────────────────────────────────────────────────────

  /// Carica la config e prova l'auto-login. Chiamato una volta da `main.dart`.
  Future<void> init() async {
    await Future.wait([
      _loadConfig(),
      _tryAutoLogin(),
    ]);
  }

  Future<void> _loadConfig() async {
    try {
      final cfg = await _configSvc.fetchConfig();
      _config = cfg;
      _configError = null;
    } on ApiException catch (e) {
      _configError = e.message;
      debugPrint('[AppProvider] Config error: $e');
    } catch (e) {
      _configError = 'Errore imprevisto durante il caricamento';
      debugPrint('[AppProvider] Config unexpected error: $e');
    } finally {
      _isLoadingConfig = false;
      notifyListeners();
    }
  }

  Future<void> _tryAutoLogin() async {
    final result = await _auth.autoLogin();
    if (result.success && result.user != null) {
      _currentUser = result.user;
      _authState = AuthState.authenticated;
    }
    // Non notifyListeners() qui — lo fa _loadConfig() nel finally
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String username, String password) async {
    final result = await _auth.login(username, password);
    if (result.success && result.user != null) {
      _currentUser = result.user;
      _authState = AuthState.authenticated;
    } else {
      _authState = _mapFailure(result.failureReason);
    }
    notifyListeners();
    return result;
  }

  // ─── Registrazione ────────────────────────────────────────────────────────

  Future<void> register({
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
    final result = await _auth.register(
      username: username,
      password: password,
      nome: nome,
      cognome: cognome,
      email: email,
      telefono: telefono,
      cf: cf,
      dataDiNascita: dataDiNascita,
      privacy1: privacy1,
      privacy2: privacy2,
      privacy3: privacy3,
      privacy4: privacy4,
    );

    _authState = result.success
        ? AuthState.registrationSuccess
        : _mapRegisterFailure(result.failureReason);
    notifyListeners();
  }

  // ─── Reset password ───────────────────────────────────────────────────────

  Future<void> resetPassword(String usernameOrEmail) async {
    final ok = await _auth.resetPassword(usernameOrEmail);
    _authState = ok ? AuthState.passwordReset : AuthState.error;
    notifyListeners();
  }

  // ─── Navigazione auth ─────────────────────────────────────────────────────

  void goToRegister() {
    _authState = AuthState.registering;
    notifyListeners();
  }

  void goToLogin() {
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }

  void goToForgotPassword() {
    _authState = AuthState.forgotPassword;
    notifyListeners();
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.logout();
    _currentUser = null;
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  AuthState _mapFailure(AuthFailureReason? reason) => switch (reason) {
    AuthFailureReason.inactiveUser    => AuthState.inactiveUser,
    AuthFailureReason.invalidCredentials => AuthState.loginFailed,
    AuthFailureReason.wrongAgencyCode => AuthState.wrongAgencyCode,
    AuthFailureReason.userAlreadyExists => AuthState.userAlreadyExists,
    _                                 => AuthState.error,
  };

  AuthState _mapRegisterFailure(RegisterFailureReason? reason) => switch (reason) {
    RegisterFailureReason.userAlreadyExists => AuthState.userAlreadyExists,
    RegisterFailureReason.wrongAgencyCode   => AuthState.wrongAgencyCode,
    _                                       => AuthState.error,
  };

  AuthService get authService => _auth;
  AppStorage get storage => _storage;
  ApiService get apiService => _api;
  String? get jwtToken => _api.jwtToken;
}
