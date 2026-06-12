/// Comunicazione in-app ricevuta dal backend (v2).
class Notifica {
  final String id;
  final String titolo;
  final String contenuto;
  final bool letta;
  final String dataora;
  final String? immagine;
  final String? link;
  final String? testolink;

  const Notifica({
    required this.id,
    required this.titolo,
    required this.contenuto,
    required this.letta,
    required this.dataora,
    this.immagine,
    this.link,
    this.testolink,
  });

  factory Notifica.fromJson(Map<String, dynamic> json) {
    return Notifica(
      id: json['id']?.toString() ?? '',
      titolo: json['titolo']?.toString() ?? '',
      // v2 uses 'testo' for body; fall back to 'contenuto' for compatibility
      contenuto: json['testo']?.toString() ?? json['contenuto']?.toString() ?? '',
      letta: json['letta'] == true || json['letta']?.toString() == '1',
      dataora: json['dataora']?.toString() ?? '',
      immagine: json['immagine']?.toString(),
      link: json['link']?.toString(),
      testolink: json['testolink']?.toString(),
    );
  }

  bool isUnreadBy(String username) => !letta;

  bool isForUser(String username) => true;
}
