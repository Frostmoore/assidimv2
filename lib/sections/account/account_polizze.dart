import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/polizza.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/responses/nessun_risultato.dart';

class AccountPolizze extends StatefulWidget {
  const AccountPolizze({super.key});

  @override
  State<AccountPolizze> createState() => _AccountPolizzeState();
}

class _AccountPolizzeState extends State<AccountPolizze> {
  late Future<List<Polizza>> _polizzeFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _polizzeFuture = provider.polizzeService.fetchPolizze(
      config: provider.config!,
      user: provider.currentUser!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Polizza>>(
      future: _polizzeFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                  color: constants.COLORE_PRINCIPALE),
            ),
          );
        }

        if (!snap.hasData || snap.data!.isEmpty) return const NessunRisultato();

        return Column(
          children: snap.data!
              .map((p) => _PolizzaCard(polizza: p))
              .toList(),
        );
      },
    );
  }
}

// ─── Policy card ─────────────────────────────────────────────────────────────

class _PolizzaCard extends StatelessWidget {
  final Polizza polizza;
  const _PolizzaCard({required this.polizza});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(polizza.dataEffettoTitolo);
    final giorniMancanti = _giorniMancanti(polizza.dataEffettoTitolo);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.shield_rounded,
              color: statusColor, size: 20),
        ),
        title: Text(
          polizza.titolo,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: polizza.descRamo != null && polizza.descRamo!.isNotEmpty
            ? Text(
                polizza.descRamo!,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (giorniMancanti != null)
              _scadenzaBadge(giorniMancanti, statusColor),
            Icon(Icons.expand_more_rounded,
                color: Colors.grey.shade400),
          ],
        ),
        children: [
          _divider(),
          const SizedBox(height: 12),
          _infoGrid(polizza),
          if (polizza.dataEffettoTitolo != null &&
              polizza.dataEffettoTitolo!.isNotEmpty)
            _progressBar(polizza.dataEffettoTitolo!),
        ],
      ),
    );
  }

  Widget _scadenzaBadge(int giorni, Color color) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          giorni < 0
              ? 'Scaduta'
              : giorni == 0
                  ? 'Oggi'
                  : '${giorni}g',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color),
        ),
      );

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
      );

  Widget _infoGrid(Polizza p) {
    final rows = <_InfoRow>[
      if (p.nominativo != null && p.nominativo!.isNotEmpty)
        _InfoRow('Contraente', p.nominativo!),
      if (p.numeroPolizza != null && p.numeroPolizza!.isNotEmpty)
        _InfoRow('N. Polizza', p.numeroPolizza!),
      if (p.descCompagnia != null && p.descCompagnia!.isNotEmpty)
        _InfoRow('Compagnia', p.descCompagnia!),
      if (p.descProdotto != null && p.descProdotto!.isNotEmpty)
        _InfoRow('Prodotto', p.descProdotto!),
      if (p.frazionamento != null && p.frazionamento!.isNotEmpty)
        _InfoRow('Frazionamento', p.frazionamento!),
      if (p.dataEffettoTitolo != null && p.dataEffettoTitolo!.isNotEmpty)
        _InfoRow('Prossima Scadenza',
            Polizza.formatDateIt(p.dataEffettoTitolo)),
      if (p.dataScadenzaContratto != null &&
          p.dataScadenzaContratto!.isNotEmpty)
        _InfoRow('Scadenza Contratto',
            Polizza.formatDateIt(p.dataScadenzaContratto)),
      if (p.descStatoPolizza != null && p.descStatoPolizza!.isNotEmpty)
        _InfoRow('Stato', p.descStatoPolizza!),
    ];

    return Column(
      children: rows
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        r.label,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.value,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _progressBar(String dataEffettoStr) {
    try {
      final dataEffetto = DateTime.parse(dataEffettoStr);
      final oggi = DateTime.now();
      DateTime prossimaRicorrenza = DateTime(
          oggi.year, dataEffetto.month, dataEffetto.day);
      if (prossimaRicorrenza.isBefore(oggi)) {
        prossimaRicorrenza = DateTime(
            oggi.year + 1, dataEffetto.month, dataEffetto.day);
      }
      final giorniMancanti =
          prossimaRicorrenza.difference(oggi).inDays.clamp(0, 365);
      final progress = 1 - (giorniMancanti / 365);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _statusColor(dataEffettoStr)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mancano $giorniMancanti giorni alla prossima rata',
            style: TextStyle(
                fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      );
    } catch (_) {
      return const SizedBox();
    }
  }

  Color _statusColor(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return Colors.green;
    try {
      final data = DateTime.parse(dateStr);
      final giorni = data.difference(DateTime.now()).inDays;
      if (giorni < 0) return Colors.red.shade300;
      if (giorni <= 10) return Colors.red;
      if (giorni <= 31) return Colors.orange;
      return Colors.green;
    } catch (_) {
      return Colors.green;
    }
  }

  int? _giorniMancanti(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final data = DateTime.parse(dateStr);
      final g = data.difference(DateTime.now()).inDays;
      if (g > 60) return null;
      return g;
    } catch (_) {
      return null;
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
