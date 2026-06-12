import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/models/polizza.dart';
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/services/api_service.dart';

/// Recupera le polizze attive tramite AssiEasy (con fallback JWT per TTYCreo).
class PolizzeService {
  final ApiService _api;

  const PolizzeService(this._api);

  Future<List<Polizza>> fetchPolizze({
    required AppConfig config,
    required UserData user,
  }) async {
    try {
      return await _fetchAssiEasy(config: config, user: user);
    } catch (e) {
      debugPrint('[Polizze] AssiEasy fallito ($e), provo JWT fallback');
      return _fetchJwtFallback(config: config, user: user);
    }
  }

  // ─── AssiEasy ─────────────────────────────────────────────────────────────

  Future<List<Polizza>> _fetchAssiEasy({
    required AppConfig config,
    required UserData user,
  }) async {
    final assiurl = config.assiurl;
    final assisecret = config.assisecret;

    final headers = {
      'chiave-hi': 'ASSIHI',
      'Host': assiurl,
      'assi_secret': assisecret,
    };

    // 1. Lookup credenziali
    final urlLookup =
        Uri.https(assiurl, 'assieasy/clienti/autenticazione/get_credenziali_utente');
    final lookupData = await _api.postForm(urlLookup, fields: {
      'username': user.username,
      'codicefiscale': user.cf,
    }, extraHeaders: headers);

    final passwordAe = lookupData['data']?['PASSWORD'] as String?;
    if (passwordAe == null || passwordAe.isEmpty) {
      throw const ApiException('Lookup AssiEasy: password non trovata');
    }

    // 2. Login
    final urlLogin =
        Uri.https(assiurl, 'assieasy/clienti/autenticazione/login');
    final loginData = await _api.postForm(urlLogin, fields: {
      'username': user.username,
      'password': passwordAe,
    }, extraHeaders: headers);

    final tokenAe = loginData['data']?['TOKEN'] as String?;
    if (tokenAe == null || tokenAe.isEmpty) {
      throw const ApiException('Login AssiEasy: token non trovato');
    }

    final authedHeaders = {...headers, 'Accept': '*/*', 'token': tokenAe};

    // 3. Polizze
    final urlPolizze = Uri.https(assiurl, 'assieasy/clienti/polizze/get');
    final polizzeData = await _api.postForm(urlPolizze, fields: {
      'ID_POLIZZA': '0',
      'SOLO_VIVE': '1',
      'sorts[1][column]': 'NUMERO_POLIZZA',
      'sorts[1][order]': 'DESC',
    }, extraHeaders: authedHeaders);

    final rawPolizze = polizzeData['data'] as List<dynamic>?;
    if (rawPolizze == null || rawPolizze.isEmpty) {
      throw const ApiException('Lista polizze AssiEasy vuota');
    }

    // 4. Titoli (per DATA_EFFETTO_TITOLO)
    final urlTitoli = Uri.https(assiurl, 'assieasy/clienti/titoli/get');
    final titoliData = await _api.postForm(urlTitoli, fields: {
      'STATO_TITOLO': '1',
    }, extraHeaders: authedHeaders);

    final rawTitoli = titoliData['data'] as List<dynamic>? ?? [];
    final titoliById = <String, String?>{};
    for (final t in rawTitoli) {
      final id = t['ID_POLIZZA']?.toString();
      if (id != null) {
        titoliById[id] = t['DATA_EFFETTO']?.toString();
      }
    }

    // 5. Merge e deserializzazione
    return rawPolizze.cast<Map<String, dynamic>>().map((raw) {
      final merged = {
        ...raw,
        'DATA_EFFETTO_TITOLO': titoliById[raw['ID_POLIZZA']?.toString()],
      };
      return Polizza.fromJson(merged);
    }).toList();
  }

  // ─── JWT fallback (TTYCreo) ───────────────────────────────────────────────

  Future<List<Polizza>> _fetchJwtFallback({
    required AppConfig config,
    required UserData user,
  }) async {
    if (config.jwturl == null ||
        config.aziendaId == null ||
        config.licenzaId == null ||
        config.agenziaId == null ||
        config.chiavePrivata == null) {
      throw const ApiException('Configurazione JWT mancante');
    }

    final jwt = _buildJwt(
      licenzaId: config.licenzaId!,
      aziendaId: config.aziendaId!,
      agenziaId: config.agenziaId!,
      chiavePrivata: config.chiavePrivata!,
    );

    final queryParams = <String, String>{};
    if (user.cf.isNotEmpty) queryParams['codice_fiscale'] = user.cf;
    if (user.piva != null && user.piva!.isNotEmpty) {
      queryParams['partita_iva'] = user.piva!;
    }

    final uri = Uri.https(config.jwturl!, '/webservice/gsvhomeinsurance/polizze', queryParams);
    final raw = await _api.getRaw(uri, headers: {
      'Authorization': 'Bearer $jwt',
      'Accept': 'application/json',
    });

    final list = (raw as Map)['data'] as List<dynamic>? ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(Polizza.fromJson)
        .toList();
  }

  String _buildJwt({
    required String licenzaId,
    required String aziendaId,
    required String agenziaId,
    required String chiavePrivata,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final payload = {
      'iss': 'GSV',
      'aud': 'Sintesi',
      'jti': const Uuid().v4(),
      'iat': now,
      'nbf': now,
      'exp': now + 300,
      'lic': licenzaId,
      'azi': aziendaId,
      'age': agenziaId,
    };

    String b64url(Map<String, dynamic> m) =>
        base64UrlEncode(utf8.encode(json.encode(m))).replaceAll('=', '');

    final encodedHeader = b64url(header);
    final encodedPayload = b64url(payload);
    final toSign = '$encodedHeader.$encodedPayload';
    final sig = base64UrlEncode(
      Hmac(sha256, utf8.encode(chiavePrivata)).convert(utf8.encode(toSign)).bytes,
    ).replaceAll('=', '');

    return '$toSign.$sig';
  }
}
