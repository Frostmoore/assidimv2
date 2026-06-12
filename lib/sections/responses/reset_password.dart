import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedback(
      icon: Icons.mark_email_read_rounded,
      iconColor: Colors.green,
      title: 'Email inviata!',
      body: 'Ti abbiamo inviato un\'email con il link per reimpostare la '
          'password. Controlla anche la cartella della posta indesiderata.',
      actions: [
        AuthFeedbackButton(
          label: 'Ho capito',
          onPressed: context.read<AppProvider>().goToLogin,
        ),
      ],
    );
  }
}
