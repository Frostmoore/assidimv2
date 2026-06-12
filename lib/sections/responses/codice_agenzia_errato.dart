import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodiceAgenziaErrato extends StatelessWidget {
  const CodiceAgenziaErrato({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedback(
      icon: Icons.domain_disabled_rounded,
      iconColor: Colors.red,
      title: 'Codice agenzia errato',
      body: 'Il codice agenzia inserito non è valido. '
          'Contatta la tua agenzia per ricevere il codice corretto.',
      actions: [
        AuthFeedbackButton(
          label: 'Indietro',
          onPressed: context.read<AppProvider>().goToLogin,
        ),
      ],
    );
  }
}
