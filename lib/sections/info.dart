import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/informazioni.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF5C6BC0),
              size: 22,
            ),
          ),
          title: Text(
            config.infoTitolo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: const [
            InformazioniAgenzie(),
          ],
        ),
      ),
    );
  }
}
