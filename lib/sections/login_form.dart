import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await context.read<AppProvider>().login(
          _username.text.trim(),
          _password.text.trim(),
        );

    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Credenziali non valide.';
        _loading = false;
      });
    }
  }

  InputDecoration _inputDeco(String label, IconData icon,
          {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        suffixIcon: suffix,
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

    return ColoredBox(
      color: const Color(0xFFF5F6F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A4A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Accedi al tuo account',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inserisci le tue credenziali per continuare.',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Login card ──
            _sectionLabel('ACCESSO'),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  color: Colors.red.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _username,
                        decoration: _inputDeco(
                            'Username, e-mail o Codice Fiscale',
                            Icons.person_rounded),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: !_passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: _inputDeco(
                          'Password',
                          Icons.key_rounded,
                          suffix: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: provider.goToForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1A2A4A),
                            padding: EdgeInsets.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Password dimenticata?',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                onPressed: _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF1A2A4A),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                child: const Text('Accedi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Register card ──
            _sectionLabel('PRIMO ACCESSO?'),
            Card(
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
                    Text(
                      'Non hai ancora un account?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registrati per accedere alle funzionalità avanzate dell\'app.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: provider.goToRegister,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A2A4A),
                          side: const BorderSide(
                              color: Color(0xFF1A2A4A)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Registrati',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 1.4,
          ),
        ),
      );
}
