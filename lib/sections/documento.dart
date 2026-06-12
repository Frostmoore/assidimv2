import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/pages/documento.dart';
import 'package:Assidim/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Documento extends StatelessWidget {
  const Documento({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return SectionCard(
      icon: Icons.folder_open_rounded,
      iconColor: const Color(0xFF1E88E5),
      title: config.documentoTitolo,
      subtitle: config.documentoTesto,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DocumentoForm()),
      ),
    );
  }
}
