import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sinistro extends StatelessWidget {
  const Sinistro({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return SectionCard(
      icon: Icons.car_crash_rounded,
      iconColor: const Color(0xFFE53935),
      title: config.denunciaTitolo,
      subtitle: config.denunciaTesto,
      onTap: () => Navigator.pushNamed(context, '/sinistro'),
    );
  }
}
