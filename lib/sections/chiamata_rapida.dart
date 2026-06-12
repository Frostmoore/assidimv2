import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class ChiamataRapida extends StatelessWidget {
  const ChiamataRapida({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return SpeedDial(
      icon: Icons.phone_rounded,
      activeIcon: Icons.close_rounded,
      backgroundColor: const Color(0xFF1A2A4A),
      foregroundColor: Colors.white,
      activeBackgroundColor: const Color(0xFF1A2A4A),
      activeForegroundColor: Colors.white,
      buttonSize: const Size(58, 58),
      childrenButtonSize: const Size(52, 52),
      elevation: 6,
      overlayColor: Colors.black,
      overlayOpacity: 0.25,
      spaceBetweenChildren: 10,
      animationCurve: Curves.easeInOutCubic,
      children: [
        if (config.quickTelefono.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.phone_rounded, size: 22),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF34C759),
            shape: const CircleBorder(),
            label: constants.CHIAMATA_RAPIDA_UNO,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
            labelBackgroundColor: Colors.white,
            elevation: 4,
            onTap: () =>
                constants.openUrl(Uri.parse('tel:${config.quickTelefono}')),
          ),
        if (config.quickWhatsapp.isNotEmpty)
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: constants.svgWhatsapp(color: Colors.white),
            ),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF25D366),
            shape: const CircleBorder(),
            label: constants.CHIAMATA_RAPIDA_DUE,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
            labelBackgroundColor: Colors.white,
            elevation: 4,
            onTap: () => constants.openUrl(Uri.parse(config.quickWhatsapp)),
          ),
        if (config.quickEmail.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.email_rounded, size: 22),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF007AFF),
            shape: const CircleBorder(),
            label: constants.CHIAMATA_RAPIDA_TRE,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
            labelBackgroundColor: Colors.white,
            elevation: 4,
            onTap: () => constants.openUrl(
                Uri.parse('mailto:${config.quickEmail}')),
          ),
      ],
    );
  }
}
