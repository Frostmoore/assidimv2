import 'package:flutter/material.dart';

class AuthFeedback extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final List<AuthFeedbackButton> actions;

  const AuthFeedback({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ...actions.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: a.outlined
                          ? OutlinedButton(
                              onPressed: a.onPressed,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A2A4A),
                                side: const BorderSide(
                                    color: Color(0xFF1A2A4A)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: Text(a.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            )
                          : FilledButton(
                              onPressed: a.onPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1A2A4A),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: Text(a.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFeedbackButton {
  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  const AuthFeedbackButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });
}
