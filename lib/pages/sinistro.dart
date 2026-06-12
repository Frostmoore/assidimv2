import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/liberatoria.dart';

class SinistroForm extends StatefulWidget {
  @override
  _SinistroFormState createState() => _SinistroFormState();
}

class _SinistroFormState extends State<SinistroForm> {
  int? selectedOption;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Controllers for Option 1 fields
  TextEditingController nomeController = TextEditingController();
  TextEditingController cognomeController = TextEditingController();
  TextEditingController indirizzoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController descrizione1Controller = TextEditingController();
  bool privacy = false;
  XFile? fotoCAI;
  XFile? fronteDoc;
  XFile? retroDoc;

  // Controllers for Option 2 fields
  TextEditingController luogoIncidenteController = TextEditingController();
  bool feriti = false;
  DateTime? dataOraIncidente;
  TextEditingController dataOraIncidenteController = TextEditingController();
  TextEditingController descrizione2Controller = TextEditingController();

  // Controllers for Contraente / Assicurato Veicolo A
  TextEditingController cognomeAController = TextEditingController();
  TextEditingController nomeAController = TextEditingController();
  TextEditingController codiceFiscaleAController = TextEditingController();
  TextEditingController indirizzoAController = TextEditingController();
  TextEditingController capAController = TextEditingController();
  TextEditingController statoAController = TextEditingController();
  TextEditingController telefonoAController = TextEditingController();
  TextEditingController emailAController = TextEditingController();

  // Controllers for Veicolo A
  TextEditingController marcaVeicoloAController = TextEditingController();
  TextEditingController targaTelaioAController = TextEditingController();
  TextEditingController statoImmatricolazioneController =
      TextEditingController();

  // Controllers for Conducente Veicolo A
  TextEditingController cognomeConducenteController = TextEditingController();
  TextEditingController nomeConducenteController = TextEditingController();
  DateTime? dataNascitaConducente;
  TextEditingController dataNascitaConducenteController =
      TextEditingController();
  TextEditingController codiceFiscaleConducenteController =
      TextEditingController();
  TextEditingController indirizzoConducenteController = TextEditingController();
  TextEditingController capConducenteController = TextEditingController();
  TextEditingController telefonoConducenteController = TextEditingController();
  TextEditingController numeroPatenteController = TextEditingController();
  TextEditingController categoriaPatenteController = TextEditingController();
  DateTime? validitaPatente;
  TextEditingController validitaPatenteController = TextEditingController();

  // Controllers for Veicolo B
  TextEditingController targaTelaioBController = TextEditingController();

  // Controllers for Option 3
  TextEditingController nome3Controller = TextEditingController();
  TextEditingController cognome3Controller = TextEditingController();
  TextEditingController indirizzo3Controller = TextEditingController();
  TextEditingController email3Controller = TextEditingController();
  TextEditingController telefono3Controller = TextEditingController();
  TextEditingController descrizione3Controller = TextEditingController();
  TextEditingController dataIncidente3Controller = TextEditingController();
  DateTime? dataIncidente3;
  XFile? documentazione;

  // Circostanze dell'Incidente
  Map<String, bool> circostanze = {
    'fermataA': false,
    'fermataB': false,
    'ripartenzaA': false,
    'ripartenzaB': false,
    'parcheggioA': false,
    'parcheggioB': false,
    'uscitaA': false,
    'uscitaB': false,
    'entrataA': false,
    'entrataB': false,
    'immissioneRotatoriaA': false,
    'immissioneRotatoriaB': false,
    'circolazioneRotatoriaA': false,
    'circolazioneRotatoriaB': false,
    'tamponamentoA': false,
    'tamponamentoB': false,
    'filaDiversaA': false,
    'filaDiversaB': false,
    'cambioFilaA': false,
    'cambioFilaB': false,
    'sorpassoA': false,
    'sorpassoB': false,
    'destraA': false,
    'destraB': false,
    'sinistraA': false,
    'sinistraB': false,
    'retromarciaA': false,
    'retromarciaB': false,
    'contromanoA': false,
    'contromanoB': false,
    'provenienzaDestraA': false,
    'provenienzaDestraB': false,
    'precedenzaA': false,
    'precedenzaB': false,
  };

  Map<String, bool> uploadStatus = {
    'fotoCAI': false,
    'fronteDoc': false,
    'retroDoc': false,
    'documentazione': false,
  };

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

  Widget _circostanzaRow(String label, String keyA, String keyB) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Checkbox(
                  value: circostanze[keyA] ?? false,
                  activeColor: const Color(0xFF1A2A4A),
                  onChanged: (v) => setState(() => circostanze[keyA] = v!),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Veicolo A', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                Checkbox(
                  value: circostanze[keyB] ?? false,
                  activeColor: const Color(0xFF1A2A4A),
                  onChanged: (v) => setState(() => circostanze[keyB] = v!),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Veicolo B', style: TextStyle(fontSize: 13)),
              ],
            ),
            Divider(height: 1, color: Colors.grey.shade100),
          ],
        ),
      );

  // ─── Image picking ────────────────────────────────────────────────────────

  void scegliFonteECarica(String key) {
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
              pickImage(ImageSource.camera, key);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Scegli dalla Galleria'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery, key);
            },
          ),
        ]),
      ),
    );
  }

  void pickImage(ImageSource source, String key) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (key == 'fotoCAI') fotoCAI = pickedFile;
      if (key == 'fronteDoc') fronteDoc = pickedFile;
      if (key == 'retroDoc') retroDoc = pickedFile;
      if (key == 'documentazione') documentazione = pickedFile;
      uploadStatus[key] = pickedFile != null;
    });
  }

  // ─── Date pickers ─────────────────────────────────────────────────────────

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (time != null) {
        setState(() {
          dataOraIncidente = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
          dataOraIncidenteController.text =
              '${dataOraIncidente!.day}/${dataOraIncidente!.month}/${dataOraIncidente!.year} ${dataOraIncidente!.hour}:${dataOraIncidente!.minute}';
        });
      }
    }
  }

  Future<void> _selectDateTimeBirth(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _selectDateTimeLicense(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _selectDateTimeSinistro(BuildContext context,
      {required TextEditingController controller,
      required Function(DateTime) onDateSelected}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (date != null) {
      setState(() {
        onDateSelected(date);
        controller.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (uploadStatus['fronteDoc'] == true &&
          uploadStatus['retroDoc'] == true) {
        final provider = context.read<AppProvider>();
        setState(() => isLoading = true);

        final Map<String, dynamic> requestData;

        if (selectedOption == 1) {
          requestData = {
            'option': 1,
            'nome': nomeController.text,
            'cognome': cognomeController.text,
            'indirizzo': indirizzoController.text,
            'email': emailController.text,
            'telefono': telefonoController.text,
            'privacy': privacy,
            'descrizione': descrizione1Controller.text,
            'dataSinistro': dataIncidente3?.toIso8601String(),
          };
        } else if (selectedOption == 2) {
          requestData = {
            'option': 2,
            'dataOraIncidente': dataOraIncidente?.toIso8601String(),
            'luogoIncidente': luogoIncidenteController.text,
            'descrizione': descrizione2Controller.text,
            'feriti': feriti,
            'contraente': {
              'cognome': cognomeAController.text,
              'nome': nomeAController.text,
              'codiceFiscale': codiceFiscaleAController.text,
              'indirizzo': indirizzoAController.text,
              'cap': capAController.text,
              'stato': statoAController.text,
              'telefono': telefonoAController.text,
              'email': emailAController.text,
            },
            'veicoloA': {
              'marca': marcaVeicoloAController.text,
              'targaTelaio': targaTelaioAController.text,
              'statoImmatricolazione': statoImmatricolazioneController.text,
            },
            'conducente': {
              'cognome': cognomeConducenteController.text,
              'nome': nomeConducenteController.text,
              'dataNascita': dataNascitaConducente?.toIso8601String(),
              'codiceFiscale': codiceFiscaleConducenteController.text,
              'indirizzo': indirizzoConducenteController.text,
              'cap': capConducenteController.text,
              'telefono': telefonoConducenteController.text,
              'numeroPatente': numeroPatenteController.text,
              'categoriaPatente': categoriaPatenteController.text,
              'validitaPatente': validitaPatente?.toIso8601String(),
            },
            'veicoloB': {
              'targaTelaio': targaTelaioBController.text,
            },
            'circostanze': circostanze,
            'privacy': privacy,
          };
        } else {
          requestData = {
            'option': 3,
            'nome': nome3Controller.text,
            'cognome': cognome3Controller.text,
            'indirizzo': indirizzo3Controller.text,
            'email': email3Controller.text,
            'telefono': telefono3Controller.text,
            'descrizione': descrizione3Controller.text,
            'privacy': privacy,
            'dataSinistro': dataIncidente3?.toIso8601String(),
          };
        }

        final url = Uri.parse(
            'https://${constants.PATH}${constants.ENDPOINT_V2_SINISTRO}');

        final files = <http.MultipartFile>[];
        if (fotoCAI != null) {
          files.add(
              await http.MultipartFile.fromPath('fotoCAI', fotoCAI!.path));
        }
        if (fronteDoc != null) {
          files.add(
              await http.MultipartFile.fromPath('fronteDoc', fronteDoc!.path));
        }
        if (retroDoc != null) {
          files.add(
              await http.MultipartFile.fromPath('retroDoc', retroDoc!.path));
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Carica le foto dei documenti prima di inviare.')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  String get _appBarTitle {
    switch (selectedOption) {
      case 1:
        return 'Auto – Modulo CAI';
      case 2:
        return 'Auto – Senza CAI';
      case 3:
        return 'Sinistro NON-Auto';
      default:
        return 'Modulo Sinistro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: Text(_appBarTitle),
        leading: selectedOption != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => selectedOption = null),
              )
            : null,
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
                    if (selectedOption == null) _buildOptionSelection(),
                    if (selectedOption != null) ...[
                      if (selectedOption == 1) _buildOption1Form(),
                      if (selectedOption == 2) _buildOption2Form(),
                      if (selectedOption == 3) _buildOption3Form(),
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
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
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Option selection screen ──────────────────────────────────────────────

  Widget _buildOptionSelection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('TIPO DI SINISTRO'),
          _optionCard(
            1,
            Icons.article_rounded,
            'Auto – Ho il modulo CAI',
            'Hai il modulo di constatazione amichevole compilato',
          ),
          const SizedBox(height: 10),
          _optionCard(
            2,
            Icons.car_crash_rounded,
            'Auto – Senza modulo CAI',
            'Incidente senza constatazione amichevole',
          ),
          const SizedBox(height: 10),
          _optionCard(
            3,
            Icons.personal_injury_rounded,
            'Sinistro NON-Auto',
            'Sinistro che non riguarda veicoli a motore',
          ),
        ],
      );

  Widget _optionCard(
      int option, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () => setState(() => selectedOption = option),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A4A).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: const Color(0xFF1A2A4A), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
  }

  // ─── Option 1 form ────────────────────────────────────────────────────────

  Widget _buildOption1Form() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DATI DELL\'INTERESSATO'),
          _card(Column(
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
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
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
                controller: dataIncidente3Controller,
                readOnly: true,
                onTap: () => _selectDateTimeSinistro(context,
                    controller: dataIncidente3Controller,
                    onDateSelected: (date) => dataIncidente3 = date),
                decoration: _inputDeco('Data del Sinistro'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizione1Controller,
                decoration: _inputDeco('Descrizione del Sinistro'),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
            ],
          )),
          _sectionLabel('DOCUMENTI'),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carica foto leggibili di tutti i documenti richiesti.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              _uploadTile('Foto Modulo CAI', 'fotoCAI',
                  () => scegliFonteECarica('fotoCAI')),
              _uploadTile('Fronte Documento di Identità', 'fronteDoc',
                  () => scegliFonteECarica('fronteDoc')),
              _uploadTile('Retro Documento di Identità', 'retroDoc',
                  () => scegliFonteECarica('retroDoc')),
            ],
          )),
        ],
      );

  // ─── Option 2 form ────────────────────────────────────────────────────────

  Widget _buildOption2Form() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DETTAGLI INCIDENTE'),
          _card(Column(
            children: [
              TextFormField(
                controller: luogoIncidenteController,
                decoration: _inputDeco('Luogo dell\'Incidente'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dataOraIncidenteController,
                readOnly: true,
                onTap: () => _selectDateTime(context),
                decoration: _inputDeco('Data e Ora dell\'Incidente'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizione2Controller,
                decoration: _inputDeco('Descrizione del Sinistro'),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: feriti,
                    activeColor: const Color(0xFF1A2A4A),
                    onChanged: (v) => setState(() => feriti = v!),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Ci sono feriti',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          )),
          _sectionLabel('CONTRAENTE / ASSICURATO VEICOLO A'),
          _card(Column(
            children: [
              TextFormField(
                controller: cognomeAController,
                decoration: _inputDeco('Cognome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nomeAController,
                decoration: _inputDeco('Nome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codiceFiscaleAController,
                decoration: _inputDeco('Codice Fiscale o Partita IVA'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: indirizzoAController,
                decoration: _inputDeco('Indirizzo'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: capAController,
                decoration: _inputDeco('CAP'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: statoAController,
                decoration: _inputDeco('Stato'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefonoAController,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco('Telefono'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailAController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('Email'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
            ],
          )),
          _sectionLabel('VEICOLO A'),
          _card(Column(
            children: [
              TextFormField(
                controller: marcaVeicoloAController,
                decoration: _inputDeco('Marca e Modello'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targaTelaioAController,
                decoration: _inputDeco('N. di Targa o Telaio'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: statoImmatricolazioneController,
                decoration: _inputDeco('Stato di Immatricolazione'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
            ],
          )),
          _sectionLabel('CONDUCENTE VEICOLO A'),
          _card(Column(
            children: [
              TextFormField(
                controller: cognomeConducenteController,
                decoration: _inputDeco('Cognome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nomeConducenteController,
                decoration: _inputDeco('Nome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dataNascitaConducenteController,
                readOnly: true,
                onTap: () => _selectDateTimeBirth(context,
                    controller: dataNascitaConducenteController,
                    onDateSelected: (date) => dataNascitaConducente = date),
                decoration: _inputDeco('Data di Nascita'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codiceFiscaleConducenteController,
                decoration: _inputDeco('Codice Fiscale'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: indirizzoConducenteController,
                decoration: _inputDeco('Indirizzo'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: capConducenteController,
                decoration: _inputDeco('CAP'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefonoConducenteController,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco('Telefono'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: numeroPatenteController,
                decoration: _inputDeco('N. Patente'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoriaPatenteController,
                decoration: _inputDeco('Categoria Patente (A, B...)'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: validitaPatenteController,
                readOnly: true,
                onTap: () => _selectDateTimeLicense(context,
                    controller: validitaPatenteController,
                    onDateSelected: (date) => validitaPatente = date),
                decoration: _inputDeco('Data Validità Patente'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
            ],
          )),
          _sectionLabel('VEICOLO B'),
          _card(TextFormField(
            controller: targaTelaioBController,
            decoration: _inputDeco('N. di Targa o Telaio'),
            validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
          )),
          _sectionLabel('CIRCOSTANZE DELL\'INCIDENTE'),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seleziona se e quale veicolo era in una delle seguenti circostanze al momento dell\'incidente.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              _circostanzaRow(
                  'Era in fermata o in sosta', 'fermataA', 'fermataB'),
              _circostanzaRow('Ripartiva dopo sosta o apriva portiera',
                  'ripartenzaA', 'ripartenzaB'),
              _circostanzaRow(
                  'Stava parcheggiando', 'parcheggioA', 'parcheggioB'),
              _circostanzaRow(
                  'Usciva da parcheggio / luogo privato / strada vicinale',
                  'uscitaA',
                  'uscitaB'),
              _circostanzaRow(
                  'Entrava in parcheggio / luogo privato / strada vicinale',
                  'entrataA',
                  'entrataB'),
              _circostanzaRow('Si immetteva in piazza a senso rotatorio',
                  'immissioneRotatoriaA', 'immissioneRotatoriaB'),
              _circostanzaRow('Circolava su piazza a senso rotatorio',
                  'circolazioneRotatoriaA', 'circolazioneRotatoriaB'),
              _circostanzaRow(
                  'Tamponava (stesso senso, stessa fila)',
                  'tamponamentoA',
                  'tamponamentoB'),
              _circostanzaRow('Procedeva stesso senso, fila diversa',
                  'filaDiversaA', 'filaDiversaB'),
              _circostanzaRow(
                  'Cambiava fila', 'cambioFilaA', 'cambioFilaB'),
              _circostanzaRow('Sorpassava', 'sorpassoA', 'sorpassoB'),
              _circostanzaRow('Girava a destra', 'destraA', 'destraB'),
              _circostanzaRow('Girava a sinistra', 'sinistraA', 'sinistraB'),
              _circostanzaRow(
                  'Retrocedeva', 'retromarciaA', 'retromarciaB'),
              _circostanzaRow(
                  'Invadeva carreggiata in senso inverso',
                  'contromanoA',
                  'contromanoB'),
              _circostanzaRow(
                  'Proveniva da destra',
                  'provenienzaDestraA',
                  'provenienzaDestraB'),
              _circostanzaRow(
                  'Non aveva osservato segnale di precedenza / semaforo rosso',
                  'precedenzaA',
                  'precedenzaB'),
            ],
          )),
          _sectionLabel('DOCUMENTI'),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carica foto leggibili di tutti i documenti richiesti.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              _uploadTile('Fronte Documento di Identità', 'fronteDoc',
                  () => scegliFonteECarica('fronteDoc')),
              _uploadTile('Retro Documento di Identità', 'retroDoc',
                  () => scegliFonteECarica('retroDoc')),
            ],
          )),
        ],
      );

  // ─── Option 3 form ────────────────────────────────────────────────────────

  Widget _buildOption3Form() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DATI DELL\'INTERESSATO'),
          _card(Column(
            children: [
              TextFormField(
                controller: nome3Controller,
                decoration: _inputDeco('Nome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cognome3Controller,
                decoration: _inputDeco('Cognome'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email3Controller,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('Email'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: indirizzo3Controller,
                decoration: _inputDeco('Indirizzo'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefono3Controller,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco('Telefono'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dataIncidente3Controller,
                readOnly: true,
                onTap: () => _selectDateTimeSinistro(context,
                    controller: dataIncidente3Controller,
                    onDateSelected: (date) => dataIncidente3 = date),
                decoration: _inputDeco('Data del Sinistro'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descrizione3Controller,
                decoration: _inputDeco('Descrizione del Sinistro'),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
              ),
            ],
          )),
          _sectionLabel('DOCUMENTI'),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carica foto leggibili di tutti i documenti richiesti.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              _uploadTile('Documento Rilevante', 'documentazione',
                  () => scegliFonteECarica('documentazione')),
              _uploadTile('Fronte Documento di Identità', 'fronteDoc',
                  () => scegliFonteECarica('fronteDoc')),
              _uploadTile('Retro Documento di Identità', 'retroDoc',
                  () => scegliFonteECarica('retroDoc')),
            ],
          )),
        ],
      );

  // ─── Privacy section ──────────────────────────────────────────────────────

  Widget _buildPrivacySection() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: const Text(
                  'Acconsento al trattamento dei miei dati personali, '
                  'così come esposto nella liberatoria Privacy.',
                  style: TextStyle(fontSize: 14),
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
