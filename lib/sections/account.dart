import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/storage/app_storage.dart';
import 'package:Assidim/sections/account/account_polizze.dart';
import 'package:Assidim/sections/account/gestione_consensi.dart';
import 'package:Assidim/sections/account/notifiche.dart';
import 'package:Assidim/sections/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final provider = context.read<AppProvider>();
    final storage = provider.storage;
    if (!provider.isAuthenticated) return;

    final bioPerm = await storage.getBiometricsPermission();
    if (bioPerm == null) {
      await _askBiometricsConsent(storage);
    } else if (bioPerm == true) {
      final bioUsed = await storage.hasBiometricsBeenUsed();
      if (!bioUsed) {
        final success = await _authenticate();
        if (success) {
          await storage.setBiometricsUsed();
        } else {
          await provider.logout();
        }
      } else {
        final success = await _authenticate();
        if (!success) await provider.logout();
      }
    }
  }

  Future<bool> _authenticate() async {
    if (!await _localAuth.canCheckBiometrics) return false;
    if (!await _localAuth.isDeviceSupported()) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Accedi con i tuoi dati biometrici per semplificare il login.',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _askBiometricsConsent(AppStorage storage) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.white),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Autenticazione Biometrica'),
          content: const HtmlWidget(
            '<p style="text-align:center;">Vuoi consentire a questa app di '
            'autenticarti tramite <strong>impronta digitale</strong> o '
            '<strong>riconoscimento facciale</strong>?<br>I tuoi dati non '
            'verranno <strong>mai trasmessi</strong> fuori dal tuo dispositivo.</p>',
          ),
          actions: [
            OutlinedButton(
              onPressed: () async {
                await storage.setBiometricsPermission(false);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A2A4A),
              ),
              onPressed: () async {
                await storage.setBiometricsPermission(true);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                final ok = await _authenticate();
                if (ok) await storage.setBiometricsUsed();
              },
              child: const Text('Sì, acconsento'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ColoredBox(
      color: const Color(0xFFF5F6F8),
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                    color: constants.COLORE_PRINCIPALE),
              ),
            );
          }

          final user = provider.currentUser;
          if (user == null) return const LoginForm();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserCard(user: user),
                const SizedBox(height: 10),
                const Notifiche(),
                _sectionLabel('LE MIE POLIZZE'),
                const AccountPolizze(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AppProvider>().logout(),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Esci dall\'account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.4,
          ),
        ),
      );
}

// ─── User card ───────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserData user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.nome, user.cognome);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _avatar(initials),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.nome} ${user.cognome}'.trim().isNotEmpty
                        ? '${user.nome} ${user.cognome}'.trim()
                        : user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings_rounded,
                  color: Colors.grey.shade400, size: 22),
              tooltip: 'Impostazioni',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const GestioneConsensi()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String nome, String cognome) {
    final n = nome.isNotEmpty ? nome[0].toUpperCase() : '';
    final c = cognome.isNotEmpty ? cognome[0].toUpperCase() : '';
    final combined = '$n$c';
    return combined.isNotEmpty ? combined : '?';
  }

  Widget _avatar(String initials) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2A4A),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      );
}
