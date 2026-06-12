/// Dati utente restituiti dal backend dopo il login.
class UserData {
  final String id;
  final String username;
  final String email;
  final String nome;
  final String cognome;
  final String cf;
  final String? piva;
  final String? playerId;
  // Privacy flags – raw values from API (format: "1|testo" or "0|testo")
  final String? privacy2;
  final String? privacy3;
  final String? privacy4;

  const UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.cf,
    this.piva,
    this.playerId,
    this.privacy2,
    this.privacy3,
    this.privacy4,
  });

  /// Il backend restituisce `{ "result": { ... }, "playerid": "...", "http_response_code": "1" }`.
  /// Questo factory riceve il sotto-oggetto `result` già estratto.
  factory UserData.fromJson(Map<String, dynamic> json, {String? playerId}) {
    return UserData(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      cognome: json['cognome']?.toString() ?? '',
      cf: json['cf']?.toString() ?? '',
      piva: json['piva']?.toString(),
      // v2: playerid is inside the user object; v1: passed separately
      playerId: playerId ?? json['playerid']?.toString(),
      privacy2: json['privacy2']?.toString(),
      privacy3: json['privacy3']?.toString(),
      privacy4: json['privacy4']?.toString(),
    );
  }

  String get nomeCompleto => '$nome $cognome'.trim();
}
