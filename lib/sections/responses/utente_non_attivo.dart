import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UtenteNonAttivo extends StatelessWidget {
  const UtenteNonAttivo({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedback(
      icon: Icons.pending_actions_rounded,
      iconColor: Colors.amber,
      title: 'Account non attivato',
      body: 'Attiva il tuo account prima di accedere. '
          'Ti abbiamo inviato un\'email con il link di attivazione durante la '
          'registrazione. Controlla anche la posta indesiderata o contatta '
          'la tua agenzia.',
      actions: [
        AuthFeedbackButton(
          label: 'Ho capito',
          onPressed: context.read<AppProvider>().goToLogin,
        ),
      ],
    );
  }
}
