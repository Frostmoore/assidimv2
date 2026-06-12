import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformazioniAgenzie extends StatelessWidget {
  const InformazioniAgenzie({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppProvider>().config!;

    return Column(
      children: [
        for (final sede in config.sedi)
          _SedeCard(sede: sede, config: config),
      ],
    );
  }
}

class _SedeCard extends StatelessWidget {
  final Sede sede;
  final AppConfig config;

  const _SedeCard({required this.sede, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.business_rounded,
                        color: Color(0xFF1A2A4A), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sede.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (sede.indirizzo.isNotEmpty)
                          Text(
                            sede.indirizzo.replaceAll('\\n', ' • '),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (sede.orari.isNotEmpty) ...[
                const SizedBox(height: 12),
                _infoRow(
                  Icons.schedule_rounded,
                  sede.testoOrari.isNotEmpty ? sede.testoOrari : 'Orari',
                  sede.orari.replaceAll('\\n', '\n'),
                ),
              ],
              if ([sede.telefono, sede.email, sede.mappa, sede.sito]
                  .any((s) => s.isNotEmpty)) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (sede.telefono.isNotEmpty)
                      _actionIcon(
                        Icons.phone_rounded,
                        'Chiama',
                        const Color(0xFF34C759),
                        () => constants.openUrl(
                            Uri.parse('tel:${sede.telefono}')),
                      ),
                    if (sede.email.isNotEmpty)
                      _actionIcon(
                        Icons.email_rounded,
                        'Email',
                        const Color(0xFF007AFF),
                        () => constants.openUrl(
                            Uri.parse('mailto:${sede.email}')),
                      ),
                    if (sede.mappa.isNotEmpty)
                      _actionIcon(
                        Icons.map_rounded,
                        'Mappa',
                        const Color(0xFFFF3B30),
                        () => constants.openUrl(Uri.parse(sede.mappa)),
                      ),
                    if (sede.sito.isNotEmpty)
                      _actionIcon(
                        Icons.language_rounded,
                        'Sito',
                        const Color(0xFF5856D6),
                        () => constants.openUrl(Uri.parse(sede.sito)),
                      ),
                  ],
                ),
              ],
              if (sede.recensioni.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        constants.openUrl(Uri.parse(sede.recensioni)),
                    icon: const Icon(Icons.star_outline_rounded, size: 17),
                    label: const Text('Lascia una Recensione'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      );

  Widget _actionIcon(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
}
