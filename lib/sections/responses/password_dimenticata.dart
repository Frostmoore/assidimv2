import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordDimenticata extends StatefulWidget {
  const PasswordDimenticata({super.key});

  @override
  State<PasswordDimenticata> createState() => _PasswordDimenticataState();
}

class _PasswordDimenticataState extends State<PasswordDimenticata> {
  final _formKey = GlobalKey<FormState>();
  final _cfController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _cfController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AppProvider>().resetPassword(_cfController.text.trim());
    if (mounted) setState(() => _loading = false);
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.fingerprint_rounded,
            size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF1A2A4A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

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
                  color: const Color(0xFF1A2A4A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.key_rounded,
                    color: Color(0xFF1A2A4A), size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reimposta la password',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Inserisci il tuo Codice Fiscale e ti invieremo un link per reimpostare la password.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cfController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDeco('Codice Fiscale'),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obbligatorio';
                        }
                        final re = RegExp(
                          r"^(?:[A-Z][AEIOU][AEIOUX]|[AEIOU]X{2}|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}(?:[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[15MR][\dLMNP-V]|[26NS][0-8LMNP-U])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM]|[AC-EHLMPR-T][26NS][9V])|(?:[02468LNQSU][048LQU]|[13579MPRTV][26NS])B[26NS][9V])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]",
                          caseSensitive: false,
                        );
                        if (!re.hasMatch(v)) {
                          return 'Codice Fiscale non valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _loading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: constants.COLORE_PRINCIPALE,
                                ),
                              ),
                            )
                          : FilledButton(
                              onPressed: _sendReset,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1A2A4A),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: const Text('Invia link',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: provider.goToLogin,
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
                        child: const Text('Indietro',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
