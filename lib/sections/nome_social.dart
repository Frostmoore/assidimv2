import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NomeSocial extends StatelessWidget {
  const NomeSocial({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return Column(
      children: [
        Text(config.nomeAgenzia, textAlign: TextAlign.center, style: constants.H1),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config.facebookAgenzia.isNotEmpty)
                IconButton(
                  onPressed: () => constants.openUrl(Uri.parse(config.facebookAgenzia)),
                  icon: constants.svgFacebook(),
                ),
              if (config.instagramAgenzia.isNotEmpty)
                IconButton(
                  onPressed: () => constants.openUrl(Uri.parse(config.instagramAgenzia)),
                  icon: constants.svgInstagram(),
                ),
              if (config.linkedinAgenzia.isNotEmpty)
                IconButton(
                  onPressed: () => constants.openUrl(Uri.parse(config.linkedinAgenzia)),
                  icon: constants.svgLinkedin(),
                ),
              if (config.googleAgenzia.isNotEmpty)
                IconButton(
                  onPressed: () => constants.openUrl(Uri.parse(config.googleAgenzia)),
                  icon: constants.svgGoogle(),
                ),
              if (config.sitoAgenzia.isNotEmpty)
                IconButton(
                  onPressed: () => constants.openUrl(Uri.parse(config.sitoAgenzia)),
                  icon: constants.IMAGE_WEBSITE,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
