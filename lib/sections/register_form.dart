import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/liberatoria.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _cf = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();

  DateTime? _dataDiNascita;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;
  bool _passwordVisible = false;

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;
  bool _isCheckedTutti = false;
  String? _formError;

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _cf.dispose();
    _username.dispose();
    _password.dispose();
    _repeatPassword.dispose();
    _email.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _toggleAll(bool v) {
    setState(() {
      _isCheckedTutti = v;
      _isChecked1 = v;
      _isChecked2 = v;
      _isChecked3 = v;
      _isChecked4 = v;
    });
  }

  void _updateTutti() {
    setState(() => _isCheckedTutti =
        _isChecked1 && _isChecked2 && _isChecked3 && _isChecked4);
  }

  void _checkPasswordStrength(String pw) {
    double s = 0;
    if (pw.length >= 8) s += 0.25;
    if (pw.length >= 12) s += 0.15;
    if (pw.contains(RegExp(r'[0-9]'))) s += 0.2;
    if (pw.contains(RegExp(r'[A-Z]')) && pw.contains(RegExp(r'[a-z]'))) {
      s += 0.2;
    }
    if (pw.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) s += 0.2;
    setState(() {
      _passwordStrength = s;
      if (pw.isEmpty) {
        _passwordStrengthLabel = '';
        _passwordStrengthColor = Colors.transparent;
      } else if (s < 0.4) {
        _passwordStrengthLabel = 'Debole';
        _passwordStrengthColor = Colors.red;
      } else if (s < 0.7) {
        _passwordStrengthLabel = 'Media';
        _passwordStrengthColor = Colors.orange;
      } else if (s < 1) {
        _passwordStrengthLabel = 'Forte';
        _passwordStrengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthLabel = 'Molto Forte';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataDiNascita = picked);
  }

  Future<void> _sendData() async {
    final dataNascitaStr = _dataDiNascita != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_dataDiNascita!)
        : null;
    await context.read<AppProvider>().register(
          username: _username.text.trim(),
          password: _password.text,
          nome: _nome.text.trim(),
          cognome: _cognome.text.trim(),
          email: _email.text.trim(),
          telefono: _telefono.text.trim(),
          cf: _cf.text.trim(),
          dataDiNascita: dataNascitaStr,
          privacy1: _isChecked1,
          privacy2: _isChecked2,
          privacy3: _isChecked3,
          privacy4: _isChecked4,
        );
  }

  void _onRegisterTap() {
    setState(() => _formError = null);
    if (!_isChecked1) {
      final msg =
          'È obbligatorio acconsentire almeno al primo punto della liberatoria.';
      setState(() => _formError = msg);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() => _formError =
          'Controlla tutti i campi, alcuni non sono validi o mancanti.');
      return;
    }
    _sendData();
  }

  Future<void> _showPrivacy(BuildContext context) {
    final config = context.read<AppProvider>().config!;
    return showDialog(
      context: context,
      builder: (ctx) => Theme(
        data:
            Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.white),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Informativa Privacy'),
          content: Liberatoria(config: config),
          actions: [
            TextButton(
              style: constants.STILE_BOTTONE,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────��───────────────

  InputDecoration _inputDeco(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: Colors.grey.shade500)
            : null,
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
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
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

  Widget _card(Widget child) => Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      );

  // ─── Build ───────────────────────────────────────────────────────���─────────

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F6F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Form(
          key: _formKey,
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
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Crea il tuo account',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compila tutti i campi per registrarti.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // ── Credenziali ──
              _sectionLabel('CREDENZIALI'),
              _card(Column(
                children: [
                  TextFormField(
                    controller: _username,
                    decoration: _inputDeco('Username',
                        icon: Icons.alternate_email_rounded),
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
                    decoration: _inputDeco('Password',
                            icon: Icons.key_rounded)
                        .copyWith(
                      suffixIcon: IconButton(
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
                    onChanged: _checkPasswordStrength,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obbligatorio';
                      if (v.length < 8) return 'Almeno 8 caratteri';
                      if (_passwordStrength < 0.7) return 'Password troppo debole';
                      return null;
                    },
                  ),
                  if (_passwordStrengthLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: _passwordStrength,
                        backgroundColor: Colors.grey.shade200,
                        color: _passwordStrengthColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forza: $_passwordStrengthLabel',
                        style: TextStyle(
                            fontSize: 11,
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _repeatPassword,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: _inputDeco('Ripeti la Password',
                        icon: Icons.key_rounded),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obbligatorio';
                      if (v != _password.text) {
                        return 'Le password non coincidono';
                      }
                      return null;
                    },
                  ),
                ],
              )),

              // ── Dati personali ──
              _sectionLabel('DATI PERSONALI'),
              _card(Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        _inputDeco('Email', icon: Icons.email_rounded),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obbligatorio';
                      final re = RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
                      if (!re.hasMatch(v)) return 'Email non valida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefono,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco('Telefono',
                        icon: Icons.phone_rounded),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obbligatorio';
                      if (!RegExp(r'^[0-9]{7,15}$').hasMatch(v)) {
                        return 'Numero non valido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nome,
                    decoration:
                        _inputDeco('Nome', icon: Icons.badge_rounded),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cognome,
                    decoration: _inputDeco('Cognome',
                        icon: Icons.badge_rounded),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cf,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDeco('Codice Fiscale',
                        icon: Icons.fingerprint_rounded),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obbligatorio';
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: TextEditingController(
                      text: _dataDiNascita != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(_dataDiNascita!)
                          : '',
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDeco('Data di Nascita',
                        icon: Icons.cake_rounded),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
                  ),
                ],
              )),

              // ── Privacy ──
              _sectionLabel('PRIVACY'),
              _card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showPrivacy(context),
                      icon: const Icon(Icons.info_outline_rounded,
                          size: 17),
                      label: const Text('Leggi l\'Informativa Privacy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Seleziona tutti
                  _PrivacyRow(
                    value: _isCheckedTutti,
                    label: 'Acconsento a tutti i trattamenti',
                    bold: true,
                    highlight: true,
                    onChanged: _toggleAll,
                  ),
                  const SizedBox(height: 8),
                  _PrivacyRow(
                    value: _isChecked1,
                    label:
                        '* Acconsento al trattamento dei dati particolari per le finalità indicate al punto 1 dell\'informativa.',
                    onChanged: (v) {
                      setState(() => _isChecked1 = v);
                      _updateTutti();
                    },
                  ),
                  const SizedBox(height: 6),
                  _PrivacyRow(
                    value: _isChecked2,
                    label: constants.PRIVACY_2,
                    onChanged: (v) {
                      setState(() => _isChecked2 = v);
                      _updateTutti();
                    },
                  ),
                  const SizedBox(height: 6),
                  _PrivacyRow(
                    value: _isChecked3,
                    label: constants.PRIVACY_3,
                    onChanged: (v) {
                      setState(() => _isChecked3 = v);
                      _updateTutti();
                    },
                  ),
                  const SizedBox(height: 6),
                  _PrivacyRow(
                    value: _isChecked4,
                    label: constants.PRIVACY_4,
                    onChanged: (v) {
                      setState(() => _isChecked4 = v);
                      _updateTutti();
                    },
                  ),
                ],
              )),

              // ── Error ──
              if (_formError != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onRegisterTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2A4A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Registrati',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),

              // ── Già registrato ──
              _sectionLabel('HAI GIÀ UN ACCOUNT?'),
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
                        'Hai già un account?',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              context.read<AppProvider>().goToLogin,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Privacy row ───────────────────────────────���─────────────────────────────

class _PrivacyRow extends StatelessWidget {
  final bool value;
  final String label;
  final bool bold;
  final bool highlight;
  final ValueChanged<bool> onChanged;

  const _PrivacyRow({
    required this.value,
    required this.label,
    required this.onChanged,
    this.bold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF1A2A4A),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: (v) => onChanged(v ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  bold ? FontWeight.w600 : FontWeight.normal,
              color: highlight ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );

    if (highlight) {
      return GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A4A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: row,
        ),
      );
    }

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: row,
    );
  }
}
