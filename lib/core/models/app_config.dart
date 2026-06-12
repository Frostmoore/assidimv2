import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Sub-models
// ─────────────────────────────────────────────────────────────────────────────

/// Una singola voce nei numeri utili (es. "Pronto Soccorso.118").
class ContactEntry {
  final String label;
  final String number;

  const ContactEntry({required this.label, required this.number});

  /// Il formato atteso dal backend è "Label.Numero".
  factory ContactEntry.fromRaw(String raw) {
    final dot = raw.indexOf('.');
    if (dot == -1) return ContactEntry(label: raw, number: '');
    return ContactEntry(
      label: raw.substring(0, dot).trim(),
      number: raw.substring(dot + 1).trim(),
    );
  }
}

/// Una sede dell'agenzia.
class Sede {
  final String nome;
  final String indirizzo;
  final String testoOrari;
  final String orari;
  final String telefono;
  final String email;
  final String mappa;
  final String sito;
  final String recensioni;

  const Sede({
    required this.nome,
    required this.indirizzo,
    required this.testoOrari,
    required this.orari,
    required this.telefono,
    required this.email,
    required this.mappa,
    required this.sito,
    required this.recensioni,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  AppConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Configurazione completa dell'app scaricata dall'endpoint `/res/api.php`.
/// Sostituisce il passaggio raw di `Map<String,dynamic>` a ogni widget.
class AppConfig {
  // Identità app
  final String osAppId;

  // Palette dinamica
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  // Agenzia
  final String nomeAgenzia;
  final String headerAgenzia;
  final String logoAgenzia;

  // Social
  final String facebookAgenzia;
  final String instagramAgenzia;
  final String linkedinAgenzia;
  final String googleAgenzia;
  final String sitoAgenzia;

  // Contatti rapidi (speed dial)
  final String quickTelefono;
  final String quickEmail;
  final String quickWhatsapp;

  // Sezione Contatti / Numeri Utili
  final String contattiTitolo;
  final List<String> numeriUtiliLabels;    // 3 categorie
  final List<Color> numeriUtiliColori;     // 3 colori categoria
  final List<ContactEntry> numeriUtiliSalute;
  final List<ContactEntry> numeriUtiliAssistenza;
  final List<ContactEntry> numeriUtiliNoleggio;

  // Sezione Info & Sedi
  final String infoTitolo;
  final List<Sede> sedi;

  // Sezioni azioni (Sinistro / Preventivo / Documento)
  final String denunciaTitolo;
  final String denunciaTesto;
  final String preventivoTitolo;
  final String preventivoTesto;
  final String documentoTitolo;
  final String documentoTesto;

  // Header polizze
  final String? polizzeHeader;

  // AssiEasy
  final String assiurl;
  final String assisecret;

  // TTYCreo / JWT (opzionali, presenti solo se configurati)
  final String? aziendaId;
  final String? licenzaId;
  final String? agenziaId;
  final String? chiavePrivata;
  final String? jwturl;

  const AppConfig({
    required this.osAppId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.nomeAgenzia,
    required this.headerAgenzia,
    required this.logoAgenzia,
    required this.facebookAgenzia,
    required this.instagramAgenzia,
    required this.linkedinAgenzia,
    required this.googleAgenzia,
    required this.sitoAgenzia,
    required this.quickTelefono,
    required this.quickEmail,
    required this.quickWhatsapp,
    required this.contattiTitolo,
    required this.numeriUtiliLabels,
    required this.numeriUtiliColori,
    required this.numeriUtiliSalute,
    required this.numeriUtiliAssistenza,
    required this.numeriUtiliNoleggio,
    required this.infoTitolo,
    required this.sedi,
    required this.denunciaTitolo,
    required this.denunciaTesto,
    required this.preventivoTitolo,
    required this.preventivoTesto,
    required this.documentoTitolo,
    required this.documentoTesto,
    this.polizzeHeader,
    required this.assiurl,
    required this.assisecret,
    this.aziendaId,
    this.licenzaId,
    this.agenziaId,
    this.chiavePrivata,
    this.jwturl,
  });

  // ─── Parser ────────────────────────────────────────────────────────────────

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    // Colori: "0xFFRRGGBB|0xFFRRGGBB|0xFFRRGGBB"
    final colori = (json['colori'] as String).split('|');
    final primaryColor = Color(int.parse(colori[0]));
    final secondaryColor = Color(int.parse(colori[1]));
    final tertiaryColor = Color(int.parse(colori[2]));

    // Numeri utili
    final nuLabels = _splitPipe(json['numeri_utili_labels']);
    final nuColori = _splitPipe(json['numeri_utili_colori'])
        .map((s) => Color(int.parse(s)))
        .toList();
    // Aggiungi colori mancanti se la lista è corta
    while (nuColori.length < 3) {
      nuColori.add(tertiaryColor);
    }

    // Sedi: tutti i campi pipe-separated, paralleli
    final nomi = _splitPipe(json['info_nomi_sedi']);
    final indirizzi = _splitPipe(json['info_indirizzi_sedi']);
    final testiOrari = _splitPipe(json['info_testo_orari']);
    final orari = _splitPipe(json['info_orari_sedi']);
    final recensioni = _splitPipe(json['info_recensioni_sedi']);
    final telefoni = _splitPipe(json['info_telefono_sedi']);
    final emails = _splitPipe(json['info_email_sedi']);
    final mappe = _splitPipe(json['info_mappa_sedi']);
    final siti = _splitPipe(json['info_sito_sedi']);

    final sedi = List.generate(nomi.length, (i) {
      return Sede(
        nome: nomi[i],
        indirizzo: indirizzi.elementAtOrNull(i) ?? '',
        testoOrari: testiOrari.elementAtOrNull(i) ?? '',
        orari: orari.elementAtOrNull(i) ?? '',
        telefono: telefoni.elementAtOrNull(i) ?? '',
        email: emails.elementAtOrNull(i) ?? '',
        mappa: mappe.elementAtOrNull(i) ?? '',
        sito: siti.elementAtOrNull(i) ?? '',
        recensioni: recensioni.elementAtOrNull(i) ?? '',
      );
    });

    // Numeri utili: "Label.Numero|Label.Numero|..."
    final nuSalute = _splitPipe(json['numeri_utili_salute'])
        .where((s) => s.isNotEmpty)
        .map(ContactEntry.fromRaw)
        .toList();
    final nuAssistenza = _splitPipe(json['numeri_utili_assistenza'])
        .where((s) => s.isNotEmpty)
        .map(ContactEntry.fromRaw)
        .toList();
    final nuNoleggio = _splitPipe(json['numeri_utili_noleggio'])
        .where((s) => s.isNotEmpty)
        .map(ContactEntry.fromRaw)
        .toList();

    return AppConfig(
      osAppId: json['os_app_id'] as String? ?? '',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      nomeAgenzia: json['nome_agenzia'] as String? ?? '',
      headerAgenzia: (json['header_agenzia'] as String? ?? '').replaceAll('\\', '/'),
      logoAgenzia: (json['logo_agenzia'] as String? ?? '').replaceAll('\\', '/'),
      facebookAgenzia: json['facebook_agenzia'] as String? ?? '',
      instagramAgenzia: json['instagram_agenzia'] as String? ?? '',
      linkedinAgenzia: json['linkedin_agenzia'] as String? ?? '',
      googleAgenzia: json['google_agenzia'] as String? ?? '',
      sitoAgenzia: json['sito_agenzia'] as String? ?? '',
      quickTelefono: json['quick_telefono'] as String? ?? '',
      quickEmail: json['quick_email'] as String? ?? '',
      quickWhatsapp: json['quick_whatsapp'] as String? ?? '',
      contattiTitolo: json['contatti_titolo'] as String? ?? '',
      numeriUtiliLabels: nuLabels,
      numeriUtiliColori: nuColori,
      numeriUtiliSalute: nuSalute,
      numeriUtiliAssistenza: nuAssistenza,
      numeriUtiliNoleggio: nuNoleggio,
      infoTitolo: json['info_titolo'] as String? ?? '',
      sedi: sedi,
      denunciaTitolo: json['denuncia_titolo'] as String? ?? '',
      denunciaTesto: json['denuncia_testo_grassetto'] as String? ?? '',
      preventivoTitolo: json['preventivo_titolo'] as String? ?? '',
      preventivoTesto: json['preventivo_testo_grassetto'] as String? ?? '',
      documentoTitolo: json['documento_titolo'] as String? ?? '',
      documentoTesto: json['documento_testo_grassetto'] as String? ?? '',
      polizzeHeader: json['polizze_header'] as String?,
      assiurl: json['assiurl'] as String? ?? '',
      assisecret: json['assisecret'] as String? ?? '',
      aziendaId: json['azienda_id'] as String?,
      licenzaId: json['licenza_id'] as String?,
      agenziaId: json['agenzia_id'] as String?,
      chiavePrivata: json['chiave_privata'] as String?,
      jwturl: json['jwturl'] as String?,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  static List<String> _splitPipe(dynamic value) {
    if (value == null || value.toString().isEmpty) return [''];
    return value.toString().split('|');
  }
}
