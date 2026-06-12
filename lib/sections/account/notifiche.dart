import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account/show_notifiche.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifiche extends StatefulWidget {
  const Notifiche({super.key});

  @override
  State<Notifiche> createState() => _NotificheState();
}

class _NotificheState extends State<Notifiche> {
  late Future<List<Notifica>> _future;
  late String _username;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _username = provider.currentUser!.username;
    _future = provider.notificheService.fetchNotifiche(_username);
  }

  @override
  Widget build(BuildContext context) {
    context.select<AppProvider, int>((p) => p.notificheTrigger);

    return FutureBuilder<List<Notifica>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: constants.COLORE_PRINCIPALE),
              ),
            ),
          );
        }

        final notifiche = snap.data ?? [];
        final unread = notifiche
            .where((n) => n.isForUser(_username) && n.isUnreadBy(_username))
            .length
            .clamp(0, 99);

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShowNotifiche()),
              ).then((_) {
                if (!mounted) return;
                setState(() {
                  _future = context
                      .read<AppProvider>()
                      .notificheService
                      .fetchNotifiche(_username);
                });
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          unread > 0
                              ? Icons.notifications_rounded
                              : Icons.notifications_none_rounded,
                          color: unread > 0
                              ? const Color(0xFF1A2A4A)
                              : Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 18, minHeight: 18),
                            child: Text(
                              unread.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comunicazioni',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          unread > 0
                              ? '$unread non ${unread == 1 ? 'letta' : 'lette'}'
                              : 'Nessuna nuova notifica',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
