import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';

class NotificaSingle extends StatefulWidget {
  final String id;
  const NotificaSingle({super.key, required this.id});

  @override
  State<NotificaSingle> createState() => _NotificaSingleState();
}

class _NotificaSingleState extends State<NotificaSingle> {
  late Future<Notifica?> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchSingle(widget.id, _username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: const Text('Comunicazione'),
      ),
      body: FutureBuilder<Notifica?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                  color: constants.COLORE_PRINCIPALE),
            );
          }

          final n = snap.data;
          if (n == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Contenuto non disponibile',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          // Mark as read – fire and forget
          context
              .read<AppProvider>()
              .notificheService
              .markAsRead(n.id, _username);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (n.titolo.isNotEmpty) ...[
                      Text(
                        n.titolo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      n.dataora,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic),
                    ),
                    Divider(
                        height: 24,
                        thickness: 1,
                        color: Colors.grey.shade100),
                    if (n.immagine != null && n.immagine!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          n.immagine!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (n.contenuto.isNotEmpty)
                      HtmlWidget(n.contenuto),
                    if (n.link != null &&
                        n.link!.isNotEmpty &&
                        n.testolink != null &&
                        n.testolink!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              constants.openUrl(Uri.parse(n.link!)),
                          icon: const Icon(
                              Icons.open_in_new_rounded, size: 17),
                          label: Text(n.testolink!),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A2A4A),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
