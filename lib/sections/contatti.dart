import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/indirizzo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Contatti extends StatelessWidget {
  const Contatti({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    final groups = <({String label, List<ContactEntry> entries})>[
      if (config.numeriUtiliLabels.isNotEmpty &&
          config.numeriUtiliLabels[0].isNotEmpty &&
          config.numeriUtiliSalute.isNotEmpty)
        (label: config.numeriUtiliLabels[0], entries: config.numeriUtiliSalute),
      if (config.numeriUtiliLabels.length > 1 &&
          config.numeriUtiliLabels[1].isNotEmpty &&
          config.numeriUtiliAssistenza.isNotEmpty)
        (
          label: config.numeriUtiliLabels[1],
          entries: config.numeriUtiliAssistenza
        ),
      if (config.numeriUtiliLabels.length > 2 &&
          config.numeriUtiliLabels[2].isNotEmpty &&
          config.numeriUtiliNoleggio.isNotEmpty)
        (
          label: config.numeriUtiliLabels[2],
          entries: config.numeriUtiliNoleggio
        ),
    ];

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
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.contacts_rounded,
              color: Color(0xFF26A69A),
              size: 22,
            ),
          ),
          title: Text(
            config.contattiTitolo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: Colors.grey.shade100),

                // ── Gruppi numeri utili ──────────────────────────────────
                for (final group in groups) ...[
                  _groupLabel(group.label),
                  for (int i = 0; i < group.entries.length; i++) ...[
                    _CallTile(entry: group.entries[i]),
                    if (i < group.entries.length - 1)
                      Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                          color: Colors.grey.shade100),
                  ],
                ],

                // ── Dove mi Trovo ────────────────────────────────────────
                if (groups.isNotEmpty)
                  Divider(height: 1, color: Colors.grey.shade100),
                _groupLabel('DOVE MI TROVO'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Indirizzo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── Call tile ───────────────────────────────────────────────────────────────

class _CallTile extends StatelessWidget {
  final ContactEntry entry;
  const _CallTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => constants.openUrl(Uri.parse('tel:${entry.number}')),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.phone_rounded,
                  size: 17, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
