import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  Eccezioni tipizzate
// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => statusCode != null
      ? 'ApiException [$statusCode]: $message'
      : 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('Timeout: il server non ha risposto in tempo');
}

// ─────────────────────────────────────────────────────────────────────────────
//  ApiService
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;
  String? _jwtToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  String? get jwtToken => _jwtToken;
  void setToken(String token) => _jwtToken = token;
  void clearToken() => _jwtToken = null;

  Map<String, String> get _authHeaders => _jwtToken != null
      ? {'Authorization': 'Bearer $_jwtToken'}
      : {};

  // ─── GET ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(Uri url) async {
    debugPrint('[API] GET $url');
    try {
      final response = await _client.get(url).timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── POST (JSON body) ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> postJson(
    Uri url, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('[API] POST $url');
    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ...?extraHeaders,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── POST (form body) ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> postForm(
    Uri url, {
    required Map<String, String> fields,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('[API] POST (form) $url');
    try {
      final response = await _client
          .post(
            url,
            headers: extraHeaders,
            body: fields,
          )
          .timeout(_timeout);
      return _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (_) {
      throw const TimeoutException();
    }
  }

  // ─── GET raw ──────────────────────────────────────────────────────────────

  Future<dynamic> getRaw(Uri url, {Map<String, String>? headers}) async {
    debugPrint('[API] GET raw $url');
    try {
      final response =
          await _client.get(url, headers: headers).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(response.body);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const TimeoutException();
    }
  }

  // ─── v2: GET → unwrap {success, data} ────────────────────────────────────

  Future<Map<String, dynamic>> getV2(Uri url) async {
    final raw = await getRaw(url, headers: _authHeaders);
    return _unwrapV2Map(raw as Map<String, dynamic>);
  }

  Future<List<dynamic>> getV2List(Uri url) async {
    final raw = await getRaw(url, headers: _authHeaders);
    return _unwrapV2List(raw as Map<String, dynamic>);
  }

  // ─── v2: POST JSON → unwrap ───────────────────────────────────────────────

  Future<Map<String, dynamic>> postJsonV2(
    Uri url, {
    required Map<String, dynamic> body,
  }) async {
    debugPrint('[API] POST v2 $url');
    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              ..._authHeaders,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseV2(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const TimeoutException();
    }
  }

  // ─── v2: PATCH JSON → unwrap ──────────────────────────────────────────────

  Future<Map<String, dynamic>> patchJsonV2(
    Uri url, {
    required Map<String, dynamic> body,
  }) async {
    debugPrint('[API] PATCH v2 $url');
    try {
      final response = await _client
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              ..._authHeaders,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseV2(response);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const TimeoutException();
    }
  }

  // ─── v2: POST multipart ───────────────────────────────────────────────────

  Future<http.StreamedResponse> postMultipartV2(
    Uri url, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    debugPrint('[API] POST multipart v2 $url');
    final request = http.MultipartRequest('POST', url);
    if (_jwtToken != null) {
      request.headers['Authorization'] = 'Bearer $_jwtToken';
    }
    request.fields.addAll(fields);
    request.files.addAll(files);
    try {
      return await request.send().timeout(_timeout);
    } on SocketException catch (e) {
      throw NetworkException('Nessuna connessione: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Errore di rete: ${e.message}');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const TimeoutException();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _parse(http.Response response) {
    debugPrint('[API] ← ${response.statusCode}');
    if (response.statusCode != 200) {
      throw ApiException(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Risposta non è JSON valido');
    }
  }

  Map<String, dynamic> _parseV2(http.Response response) {
    debugPrint('[API] v2 ← ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          body['error']?.toString() ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return _unwrapV2Map(body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException('Risposta non è JSON valido');
    }
  }

  Map<String, dynamic> _unwrapV2Map(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw ApiException(
        json['error']?.toString() ?? 'Errore sconosciuto',
        code: json['code']?.toString(),
      );
    }
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  List<dynamic> _unwrapV2List(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw ApiException(
        json['error']?.toString() ?? 'Errore sconosciuto',
        code: json['code']?.toString(),
      );
    }
    return json['data'] as List<dynamic>? ?? [];
  }

  void dispose() => _client.close();
}
