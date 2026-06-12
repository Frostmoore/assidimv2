import 'package:Assidim/sections/responses/auth_feedback.dart';
import 'package:flutter/material.dart';

class NessunRisultato extends StatelessWidget {
  const NessunRisultato({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthFeedback(
      icon: Icons.shield_outlined,
      iconColor: Colors.grey,
      title: 'Nessuna polizza trovata',
      body: 'Non risultano polizze associate al tuo account. '
          'Per assistenza contatta la tua agenzia.',
    );
  }
}
