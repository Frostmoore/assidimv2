import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/notifica.dart';
import 'package:Assidim/core/services/api_service.dart';

/// Gestisce il recupero e la marcatura di lettura delle notifiche in-app (v2).
class NotificheService {
  final ApiService _api;

  const NotificheService(this._api);

  /// Restituisce le notifiche dell'utente autenticato (filtrate dal server via JWT).
  Future<List<Notifica>> fetchNotifiche(String username) async {
    final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_NOTI);
    final list = await _api.getV2List(url);
    return list.cast<Map<String, dynamic>>().map(Notifica.fromJson).toList();
  }

  /// Segna la notifica come letta (JWT identifica l'utente).
  Future<void> markAsRead(String notificaId, String username) async {
    final url = Uri.https(constants.PATH, constants.ENDPOINT_V2_NOTI);
    await _api.postJsonV2(url, body: {'id': notificaId});
  }

  /// Recupera i dettagli di una singola notifica.
  Future<Notifica?> fetchSingle(String notificaId, String username) async {
    final url = Uri.https(
      constants.PATH,
      constants.ENDPOINT_V2_NOTI,
      {'id': notificaId},
    );
    try {
      final data = await _api.getV2(url);
      return Notifica.fromJson(data);
    } on ApiException {
      return null;
    }
  }
}
