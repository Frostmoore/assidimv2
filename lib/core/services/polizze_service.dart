import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';
import 'package:Assidim/core/models/polizza.dart';
import 'package:Assidim/core/models/user_data.dart';
import 'package:Assidim/core/services/api_service.dart';

/// Recupera le polizze da TRE fonti indipendenti e le unisce.
///
/// - **AssiEasy** — parte se l'agenzia ha `assiurl` e `assisecret`.
/// - **Sintesi** — parte se l'agenzia ha i parametri sintesi valorizzati.
/// - **Nostro server** — parte **sempre**: sono le polizze caricate a mano
///   dall'area agency, e si devono vedere anche quando il gestionale risponde.
///
/// Non c'e' nessuna cascata e nessun fallback: le tre fonti sono alternative
/// solo nel senso che un'agenzia puo' averne configurate zero, una o tutte.
/// Ognuna ha il suo try/catch, quindi se una non risponde le altre si vedono
/// comunque. Il risultato finale e' deduplicato per numero di polizza e
/// ordinato per prossima scadenza.
class PolizzeService {
  final ApiService _api;

  const PolizzeService(this._api);

  Future<List<Polizza>> fetchPolizze({
    required AppConfig config,
    required UserData user,
  }) async {
    final polizze = <Polizza>[];

    // Provider AssiEasy — se l'agenzia ha assiurl + assisecret
    if (config.assiurl.isNotEmpty && config.assisecret.isNotEmpty) {
      try {
        polizze.addAll(await _fetchAssiEasy(config: config, user: user));
      } catch (e) {
        debugPrint('[Polizze] AssiEasy non disponibile ($e)');
      }
    }

    // Provider Sintesi — se l'agenzia ha i parametri sintesi valorizzati
    if (_hasSintesiConfig(config)) {
      try {
        polizze.addAll(await _fetchSintesi(config: config, user: user));
      } catch (e) {
        debugPrint('[Polizze] Sintesi non disponibile ($e)');
      }
    }

    // Nostro server — SEMPRE, senza condizioni sulla configurazione
    // dell'agenzia. Non e' un fallback per quando gli altri due non vanno: e'
    // una terza fonte che si somma, e le polizze caricate a mano si vedono
    // anche quando il gestionale risponde (decisione utente 2026-10-26).
    try {
      polizze.addAll(await _fetchNostroServer());
    } catch (e) {
      debugPrint('[Polizze] nostro server non disponibile ($e)');
    }

    return _ordinaETogliDoppioni(polizze);
  }

  /// Polizze caricate a mano nell'area agency, lette dal nostro backend.
  ///
  /// Nessun parametro: l'utente e l'agenzia li ricava il server dal JWT, e
  /// [ApiService.getV2] mette gia' l'header di autenticazione. Se non e' stato
  /// importato niente la risposta e' una lista vuota, e non si vede nulla.
  Future<List<Polizza>> _fetchNostroServer() async {
    final data =
        await _api.getV2(constants.apiUri(constants.ENDPOINT_V2_POLIZZE));
    final lista = data['polizze'];
    if (lista is! List) return const [];
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Polizza.fromServerJson)
        .toList();
  }

  /// Unisce le fonti togliendo i doppioni e ordinando per prossima scadenza.
  ///
  /// Una stessa polizza puo' arrivare due volte: dal gestionale e, se e' stata
  /// anche importata a mano, dal nostro server. A pari numero di polizza vince
  /// la **prima** incontrata, e poiche' il nostro server e' interrogato per
  /// ultimo vince sempre il gestionale: e' la fonte viva, mentre le nostre sono
  /// una copia caricata a mano che puo' essere vecchia. Le polizze senza numero
  /// non si possono confrontare e si tengono tutte.
  ///
  /// L'ordinamento serve perche' le fonti arrivano concatenate: senza, la lista
  /// sembrerebbe in ordine casuale all'utente. Quelle senza data vanno in fondo.
  List<Polizza> _ordinaETogliDoppioni(List<Polizza> polizze) {
    final visti = <String>{};
    final uniche = <Polizza>[];
    for (final p in polizze) {
      final numero = p.numeroPolizza?.trim().toUpperCase();
      if (numero == null || numero.isEmpty) {
        uniche.add(p);
      } else if (visti.add(numero)) {
        uniche.add(p);
      } else {
        debugPrint('[Polizze] doppione scartato: $numero');
      }
    }

    uniche.sort((a, b) {
      final da = a.dataEffettoTitolo;
      final db = b.dataEffettoTitolo;
      if (da == null || da.isEmpty) return (db == null || db.isEmpty) ? 0 : 1;
      if (db == null || db.isEmpty) return -1;
      return da.compareTo(db); // le date sono "YYYY-MM-DD": l'ordine testuale e' quello giusto
    });
    return uniche;
  }

  bool _hasSintesiConfig(AppConfig config) =>
      config.jwturl != null &&
      config.aziendaId != null &&
      config.licenzaId != null &&
      config.agenziaId != null &&
      config.chiavePrivata != null;

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

    // 1. Lookup credenziali — prova lo username, poi l'email (lo username
    //    dell'app può non combaciare con quello registrato su AssiEasy).
    final urlLookup =
        Uri.https(assiurl, 'assieasy/clienti/autenticazione/get_credenziali_utente');

    String? passwordAe;
    String aeUsername = user.username;
    final candidates = <String>{user.username, user.email}
        .where((c) => c.isNotEmpty);
    for (final candidate in candidates) {
      final lookupData = await _api.postForm(urlLookup, fields: {
        'username': candidate,
        'codicefiscale': user.cf,
      }, extraHeaders: headers);
      final pw = lookupData['data']?['PASSWORD'] as String?;
      if (pw != null && pw.isNotEmpty) {
        passwordAe = pw;
        aeUsername = candidate;
        break;
      }
    }
    if (passwordAe == null) {
      // Nessuna credenziale AssiEasy per questo utente → nessuna polizza qui.
      return <Polizza>[];
    }

    // 2. Login con l'identificativo che ha funzionato (username o email)
    final urlLogin =
        Uri.https(assiurl, 'assieasy/clienti/autenticazione/login');
    final loginData = await _api.postForm(urlLogin, fields: {
      'username': aeUsername,
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
      return <Polizza>[];
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

  // ─── Sintesi (JWT) ────────────────────────────────────────────────────────

  Future<List<Polizza>> _fetchSintesi({
    required AppConfig config,
    required UserData user,
  }) async {

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
