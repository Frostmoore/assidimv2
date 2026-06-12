import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/notifiche.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser!;
    final saluto =
        '<p style="text-align:center">Ciao, <strong>${user.nome}</strong>!<br>'
        'Qui potrai controllare lo stato delle tue polizze e verificarne la data di scadenza.</p>';

    return Column(
      children: [
        constants.SPACER_MEDIUM,
        const Notifiche(),
        constants.SPACER,
        const Text(
          'LE MIE POLIZZE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        HtmlWidget(saluto),
        constants.SPACER_MEDIUM,
        ElevatedButton(
          style: constants.STILE_BOTTONE_ROSSO,
          onPressed: () => context.read<AppProvider>().logout(),
          child: const Text('Esci'),
        ),
      ],
    );
  }
}
