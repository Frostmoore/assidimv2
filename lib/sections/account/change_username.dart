import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/core/services/api_service.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key, required this.userData});
  final UserData userData;

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final _formKey = GlobalKey<FormState>();
  final _uCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _uCtrl.text = widget.userData.username;
    _mCtrl.text = widget.userData.email;
  }

  @override
  void dispose() {
    _uCtrl.dispose();
    _mCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_ME);
    final provider = context.read<AppProvider>();

    try {
      await provider.apiService.patchJsonV2(url, body: {
        'username': _uCtrl.text.trim(),
        'email': _mCtrl.text.trim(),
      });
      await provider.storage.saveCredentials(
        username: _uCtrl.text.trim(),
        password: '',
      );
      _showSnack('Credenziali aggiornate');
    } on ApiException catch (e) {
      debugPrint('[CHANGE] errore: $e');
      _showSnack('Aggiornamento non riuscito');
    } catch (e) {
      debugPrint('[CHANGE] errore: $e');
      _showSnack('Errore di rete');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_busy)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(),
            ),
          if (_busy) const SizedBox(height: 12),
          TextFormField(
            controller: _uCtrl,
            decoration: _inputDeco('Username', Icons.person_rounded),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _mCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDeco('E-mail', Icons.email_rounded),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email non valida' : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A2A4A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Salva modifiche'),
            ),
          ),
        ],
      ),
    );
  }
}
