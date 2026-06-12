import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/notifica_single.dart';

class ShowNotifiche extends StatefulWidget {
  const ShowNotifiche({super.key});

  @override
  State<ShowNotifiche> createState() => _ShowNotificheState();
}

class _ShowNotificheState extends State<ShowNotifiche> {
  late Future<List<Notifica>> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchNotifiche(_username);
  }

  void _refresh() {
    setState(() {
      _future = context
          .read<AppProvider>()
          .notificheService
          .fetchNotifiche(_username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: const Text('Comunicazioni'),
      ),
      body: FutureBuilder<List<Notifica>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                  color: constants.COLORE_PRINCIPALE),
            );
          }

          final all = snap.data ?? [];
          final personal =
              all.where((n) => n.isForUser(_username)).toList();

          if (personal.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Nessuna comunicazione disponibile',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: personal.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = personal[i];
              final unread = n.isUnreadBy(_username);
              return _NotificaTile(
                notifica: n,
                unread: unread,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NotificaSingle(id: n.id)),
                  ).then((_) => _refresh());
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificaTile extends StatelessWidget {
  final Notifica notifica;
  final bool unread;
  final VoidCallback onTap;

  const _NotificaTile({
    required this.notifica,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: unread
              ? const Color(0xFF1A2A4A).withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unread
                      ? const Color(0xFF1A2A4A).withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  unread ? Icons.mail_rounded : Icons.mark_email_read_rounded,
                  color: unread
                      ? const Color(0xFF1A2A4A)
                      : Colors.grey.shade400,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifica.dataora,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notifica.titolo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unread
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notifica.contenuto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: unread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
