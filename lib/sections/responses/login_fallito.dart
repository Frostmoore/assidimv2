import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginFallito extends StatelessWidget {
  const LoginFallito({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return AuthFeedback(
      icon: Icons.lock_open_rounded,
      iconColor: Colors.orange,
      title: 'Accesso non riuscito',
      body: 'Non siamo riusciti a farti accedere. Assicurati di aver attivato '
          'il tuo account tramite il link inviato per mail (controlla anche la '
          'posta indesiderata), oppure reimposta la password.',
      actions: [
        AuthFeedbackButton(
          label: 'Password dimenticata?',
          outlined: true,
          onPressed: provider.goToForgotPassword,
        ),
        AuthFeedbackButton(
          label: 'Indietro',
          onPressed: () async {
            await provider.logout();
            provider.goToLogin();
          },
        ),
      ],
    );
  }
}
