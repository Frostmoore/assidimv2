/// Polizza assicurativa restituita da AssiEasy (merge con titoli).
class Polizza {
  final String? idPolizza;
  final String? numeroPolizza;
  final String? nominativo;
  final String? targa;
  final String? descRamo;
  final String? descCompagnia;
  final String? descProdotto;
  final String? frazionamento;
  final String? dataEffettoUltimaCopertura;
  final String? dataScadenzaContratto;
  final String? descStatoPolizza;
  // Aggiunto dal merge con titoli
  final String? dataEffettoTitolo;

  const Polizza({
    this.idPolizza,
    this.numeroPolizza,
    this.nominativo,
    this.targa,
    this.descRamo,
    this.descCompagnia,
    this.descProdotto,
    this.frazionamento,
    this.dataEffettoUltimaCopertura,
    this.dataScadenzaContratto,
    this.descStatoPolizza,
    this.dataEffettoTitolo,
  });

  factory Polizza.fromJson(Map<String, dynamic> json) {
    return Polizza(
      idPolizza: json['ID_POLIZZA']?.toString(),
      numeroPolizza: json['NUMERO_POLIZZA']?.toString(),
      nominativo: json['NOMINATIVO']?.toString(),
      targa: json['TARGA']?.toString(),
      descRamo: json['DESC_RAMO']?.toString(),
      descCompagnia: json['DESC_COMPAGNIA']?.toString(),
      descProdotto: json['DESC_PRODOTTO']?.toString(),
      frazionamento: json['FRAZIONAMENTO']?.toString(),
      dataEffettoUltimaCopertura: json['DATA_EFFETTO_ULTIMA_COPERTURA']?.toString(),
      dataScadenzaContratto: json['DATA_SCADENZA_CONTRATTO']?.toString(),
      descStatoPolizza: json['DESC_STATO_POLIZZA']?.toString(),
      dataEffettoTitolo: json['DATA_EFFETTO_TITOLO']?.toString(),
    );
  }

  String get titolo {
    final ramo = descRamo ?? '';
    final t = targa?.trim() ?? '';
    return t.isNotEmpty ? 'Polizza $ramo - $t' : 'Polizza $ramo';
  }

  /// Formatta una data "YYYY-MM-DD" in "DD/MM/YYYY".
  static String formatDateIt(String? date) {
    if (date == null || date.isEmpty) return '-';
    final parts = date.split('-');
    if (parts.length != 3) return date;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
