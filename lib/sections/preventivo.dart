import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Preventivo extends StatelessWidget {
  const Preventivo({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return SectionCard(
      icon: Icons.calculate_rounded,
      iconColor: const Color(0xFFF57C00),
      title: config.preventivoTitolo,
      subtitle: config.preventivoTesto,
      onTap: () => Navigator.pushNamed(context, '/preventivo'),
    );
  }
}
