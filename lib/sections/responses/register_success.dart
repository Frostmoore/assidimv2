import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterSuccess extends StatelessWidget {
  const RegisterSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedback(
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      title: 'Registrazione completata!',
      body: 'Il tuo account è stato creato con successo. '
          'Controlla la tua email per attivarlo, poi accedi.',
      actions: [
        AuthFeedbackButton(
          label: 'Accedi',
          onPressed: context.read<AppProvider>().goToLogin,
        ),
      ],
    );
  }
}
