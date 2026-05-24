import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transportista.dart';

/// Servicio centralizado para llamadas HTTP a la API de Nexus.
class ApiService {
  ApiService._();

  static const String _baseUrl = 'http://127.0.0.1:8000';

  // ── Perfiles ───────────────────────────────────────────────────
  /// Registra un perfil de transportista vía POST /perfiles/.
  static Future<Map<String, dynamic>> crearPerfilTransportista(
      Transportista transportista) async {
    final url = Uri.parse('$_baseUrl/perfiles/');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transportista.toJson()),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        return json.decode(respuesta.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Error del servidor: ${respuesta.statusCode}',
          statusCode: respuesta.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }

  // ── Rutas ──────────────────────────────────────────────────────
  /// Obtiene la lista de rutas disponibles vía GET /rutas/.
  static Future<List<dynamic>> obtenerRutas() async {
    final url = Uri.parse('$_baseUrl/rutas/');

    try {
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body) as List<dynamic>;
      } else {
        debugPrint('Error en el servidor: ${respuesta.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return [];
    }
  }
}

/// Excepción personalizada para errores de API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
