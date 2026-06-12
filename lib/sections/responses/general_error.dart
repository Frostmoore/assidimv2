import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneralError extends StatelessWidget {
  const GeneralError({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedback(
      icon: Icons.cloud_off_rounded,
      iconColor: Colors.red,
      title: 'Si è verificato un errore',
      body: 'Qualcosa è andato storto. Controlla la connessione e riprova più tardi.',
      actions: [
        AuthFeedbackButton(
          label: 'Indietro',
          onPressed: context.read<AppProvider>().goToLogin,
        ),
      ],
    );
  }
}
