import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/contatti.dart';
import 'package:Assidim/sections/documento.dart';
import 'package:Assidim/sections/info.dart';
import 'package:Assidim/sections/notifica.dart';
import 'package:Assidim/sections/preventivo.dart';
import 'package:Assidim/sections/sinistro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return ColoredBox(
      color: const Color(0xFFF5F6F8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(config: config),
            _QuickContactCard(config: config),
            const Notifica(),
            const _SectionLabel('SERVIZI'),
            const Sinistro(),
            const Preventivo(),
            const Documento(),
            const _SectionLabel('INFORMAZIONI'),
            const Info(),
            const Contatti(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final AppConfig config;
  const _HeroHeader({required this.config});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            constants.IMG_PATH + config.headerAgenzia,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF1A2A4A)),
          ),
          // Gradient overlay (top-to-bottom: light → dark)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xBB000000)],
              ),
            ),
          ),
          // Logo + name + socials
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo circle
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black38, blurRadius: 12, spreadRadius: 2),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    constants.IMG_PATH + config.logoAgenzia,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.business),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Agency name
              Text(
                config.nomeAgenzia,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 10),
              // Social icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (config.facebookAgenzia.isNotEmpty)
                    _socialBtn(
                      () => constants.openUrl(Uri.parse(config.facebookAgenzia)),
                      constants.svgFacebook(),
                    ),
                  if (config.instagramAgenzia.isNotEmpty)
                    _socialBtn(
                      () => constants.openUrl(Uri.parse(config.instagramAgenzia)),
                      constants.svgInstagram(),
                    ),
                  if (config.linkedinAgenzia.isNotEmpty)
                    _socialBtn(
                      () => constants.openUrl(Uri.parse(config.linkedinAgenzia)),
                      constants.svgLinkedin(),
                    ),
                  if (config.googleAgenzia.isNotEmpty)
                    _socialBtn(
                      () => constants.openUrl(Uri.parse(config.googleAgenzia)),
                      constants.svgGoogle(),
                    ),
                  if (config.sitoAgenzia.isNotEmpty)
                    _socialBtn(
                      () => constants.openUrl(Uri.parse(config.sitoAgenzia)),
                      constants.IMAGE_WEBSITE,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(VoidCallback onTap, Widget icon) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: FittedBox(fit: BoxFit.contain, child: icon),
        ),
      ),
    ),
  );
}

// ─── Quick contact card ───────────────────────────────────────────────────────

class _QuickContactCard extends StatelessWidget {
  final AppConfig config;
  const _QuickContactCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final hasAny = config.quickTelefono.isNotEmpty ||
        config.quickWhatsapp.isNotEmpty ||
        config.quickEmail.isNotEmpty;
    if (!hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (config.quickTelefono.isNotEmpty)
                _contactBtn(
                  icon: Icons.phone_rounded,
                  label: 'Chiama',
                  color: const Color(0xFF34C759),
                  onTap: () => constants
                      .openUrl(Uri.parse('tel:${config.quickTelefono}')),
                ),
              if (config.quickWhatsapp.isNotEmpty)
                _contactBtn(
                  icon: Icons.chat_rounded,
                  customIcon: SizedBox(
                      width: 26,
                      height: 26,
                      child: constants.svgWhatsapp(color: const Color(0xFF1A7A3C))),
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () =>
                      constants.openUrl(Uri.parse(config.quickWhatsapp)),
                ),
              if (config.quickEmail.isNotEmpty)
                _contactBtn(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  color: const Color(0xFF007AFF),
                  onTap: () => constants
                      .openUrl(Uri.parse('mailto:${config.quickEmail}')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactBtn({
    required IconData icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: customIcon ?? Icon(icon, color: color, size: 26),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
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
}
