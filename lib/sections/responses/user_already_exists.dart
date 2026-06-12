import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserAlreadyExists extends StatelessWidget {
  const UserAlreadyExists({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return AuthFeedback(
      icon: Icons.person_search_rounded,
      iconColor: Colors.orange,
      title: 'Account già esistente',
      body: 'Un utente con il Codice Fiscale inserito esiste già. '
          'Accedi con le tue credenziali o recupera la password.',
      actions: [
        AuthFeedbackButton(
          label: 'Accedi',
          onPressed: provider.goToLogin,
        ),
        AuthFeedbackButton(
          label: 'Recupera password',
          outlined: true,
          onPressed: provider.goToForgotPassword,
        ),
      ],
    );
  }
}
