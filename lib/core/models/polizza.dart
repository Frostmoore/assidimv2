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

  /// Polizza che arriva dal NOSTRO server (endpoint v2 `polizze/index.php`),
  /// cioe' una di quelle caricate a mano dall'area agency.
  ///
  /// Serve una factory separata perche' i nomi dei campi sono diversi: AssiEasy
  /// li manda MAIUSCOLI, il nostro endpoint usa i nomi delle colonne della
  /// tabella `polizze`. Si traduce qui invece di cambiare la risposta del
  /// server, che e' il porting fedele di un contratto v2 gia' esistente.
  ///
  /// `data_scadenza_titolo` finisce in [dataEffettoTitolo] di proposito: e'
  /// quel campo che la schermata mostra come "Prossima Scadenza" e usa per il
  /// conto alla rovescia, il colore e la barra. La scadenza del titolo corrente
  /// e la decorrenza del successivo sono lo stesso istante, quindi il
  /// significato combacia.
  ///
  /// [idPolizza] resta nullo: e' l'identificativo del gestionale esterno, e il
  /// nostro database non ne ha uno.
  factory Polizza.fromServerJson(Map<String, dynamic> json) {
    String? v(String chiave) {
      final s = json[chiave]?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return Polizza(
      numeroPolizza: v('n_polizza'),
      nominativo: v('contraente'),
      targa: v('targa'),
      descRamo: v('ramo'),
      descCompagnia: v('compagnia'),
      descProdotto: v('prodotto'),
      frazionamento: v('frazionamento'),
      dataEffettoUltimaCopertura: v('data_decorrenza'),
      dataScadenzaContratto: v('data_scadenza_contratto'),
      descStatoPolizza: v('stato_polizza'),
      dataEffettoTitolo: v('data_scadenza_titolo'),
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
