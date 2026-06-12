import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/liberatoria.dart';

class PreventivoForm extends StatefulWidget {
  @override
  _PreventivoFormState createState() => _PreventivoFormState();
}

class _PreventivoFormState extends State<PreventivoForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool isLoading = false;

  final nomeController = TextEditingController();
  final cognomeController = TextEditingController();
  final indirizzoController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final descrizioneController = TextEditingController();
  bool privacy = false;
  XFile? fronteDoc;
  XFile? retroDoc;
  XFile? documentazione;

  Map<String, bool> uploadStatus = {
    'fronteDoc': false,
    'retroDoc': false,
    'documentazione': false,
  };

  @override
  void dispose() {
    nomeController.dispose();
    cognomeController.dispose();
    indirizzoController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    descrizioneController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
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
          borderSide: const BorderSide(color: Color(0xFF1A2A4A), width: 1.5),
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

  Widget _uploadTile(String label, String key, VoidCallback onTap) {
    final ok = uploadStatus[key] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: ok ? Colors.green.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ok ? Colors.green.shade200 : Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ok
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              ok ? Icons.check_rounded : Icons.upload_file_rounded,
              color: ok ? Colors.green : Colors.grey.shade500,
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: ok ? Colors.green.shade700 : Colors.black87,
            ),
          ),
          trailing: ok
              ? const Icon(Icons.check_circle_rounded, color: Colors.green)
              : Icon(Icons.add_rounded, color: Colors.grey.shade400),
        ),
      ),
    );
  }

  // ─── Image picking ────────────────────────────────────────────────────────

  void _scegliFonteECarica(String key) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text('Scatta con Fotocamera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, key);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Scegli dalla Galleria'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, key);
            },
          ),
        ]),
      ),
    );
  }

  void _pickImage(ImageSource source, String key) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (key == 'fronteDoc') fronteDoc = pickedFile;
      if (key == 'retroDoc') retroDoc = pickedFile;
      if (key == 'documentazione') documentazione = pickedFile;
      uploadStatus[key] = pickedFile != null;
    });
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final provider = context.read<AppProvider>();
    final requestData = {
      'nome': nomeController.text,
      'cognome': cognomeController.text,
      'indirizzo': indirizzoController.text,
      'email': emailController.text,
      'telefono': telefonoController.text,
      'privacy': privacy,
      'descrizione': descrizioneController.text,
    };

    final url = Uri.parse(
        'https://${constants.PATH}${constants.ENDPOINT_V2_PREVENTIVO}');

    final files = <http.MultipartFile>[];
    if (fronteDoc != null) {
      files.add(await http.MultipartFile.fromPath('fronteDoc', fronteDoc!.path));
    }
    if (retroDoc != null) {
      files.add(await http.MultipartFile.fromPath('retroDoc', retroDoc!.path));
    }
    if (documentazione != null) {
      files.add(await http.MultipartFile.fromPath(
          'documentazione', documentazione!.path));
    }

    try {
      final response = await provider.apiService.postMultipartV2(
        url,
        fields: {'data': jsonEncode(requestData)},
        files: files,
      );
      setState(() => isLoading = false);
      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        await response.stream.drain<void>();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dati inviati con successo!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nell\'invio dei dati!')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Richiesta Preventivo'),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    constants.COLORE_PRINCIPALE),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('DATI PERSONALI'),
                    _card(_buildCampiPersonali()),
                    _sectionLabel('DOCUMENTI'),
                    _card(_buildUploadSection()),
                    _sectionLabel('PRIVACY'),
                    _card(_buildPrivacySection()),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 12, 68, 22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Invia il Modulo',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCampiPersonali() => Column(
        children: [
          TextFormField(
            controller: nomeController,
            decoration: _inputDeco('Nome'),
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: cognomeController,
            decoration: _inputDeco('Cognome'),
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: indirizzoController,
            decoration: _inputDeco('Indirizzo'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDeco('Email'),
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            decoration: _inputDeco('Telefono'),
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descrizioneController,
            decoration: _inputDeco('Descrizione della Richiesta'),
            maxLines: 5,
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          ),
        ],
      );

  Widget _buildUploadSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carica foto leggibili dei documenti richiesti.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          _uploadTile(
            'Fronte Documento di Identità',
            'fronteDoc',
            () => _scegliFonteECarica('fronteDoc'),
          ),
          _uploadTile(
            'Retro Documento di Identità',
            'retroDoc',
            () => _scegliFonteECarica('retroDoc'),
          ),
          _uploadTile(
            'Documento Rilevante (opzionale)',
            'documentazione',
            () => _scegliFonteECarica('documentazione'),
          ),
        ],
      );

  Widget _buildPrivacySection() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Acconsento al trattamento dei miei dati personali, '
                  'così come esposto nella liberatoria Privacy.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Checkbox(
                value: privacy,
                activeColor: const Color.fromARGB(255, 12, 68, 22),
                onChanged: (v) => setState(() => privacy = v!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLiberatoria(context),
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: const Text('Leggi la Liberatoria Privacy'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );

  void _showLiberatoria(BuildContext context) {
    final config = context.read<AppProvider>().config!;
    showDialog<void>(
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
}
