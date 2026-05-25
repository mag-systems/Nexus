import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transportista.dart';

/// Servicio centralizado para llamadas HTTP a la API de Nexus.
class ApiService {
  ApiService._();

  /// IP/host del servidor — cambiar aquí para apuntar a otro entorno.
  static const String _baseUrl = 'http://192.168.100.6:8000';

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

  // ── Perfil Socio Nexus (MultipartRequest) ──────────────────────
  /// Registra un perfil de Socio Nexus enviando texto + imágenes
  /// como `multipart/form-data` a `POST /perfiles/`.
  static Future<Map<String, dynamic>> crearPerfilSocioNexus({
    required String nombreCompleto,
    required String correo,
    required String password,
    required String modeloCarro,
    required String placas,
    required File fotoPerfil,
    File? fotoCarro,
  }) async {
    final url = Uri.parse('$_baseUrl/perfiles/');

    try {
      final request = http.MultipartRequest('POST', url);

      // Campos de texto
      request.fields['tipo_usuario'] = 'socio_nexus';
      request.fields['nombre_completo'] = nombreCompleto;
      request.fields['correo'] = correo;
      request.fields['password'] = password;
      request.fields['modelo_carro'] = modeloCarro;
      request.fields['placas'] = placas;

      // Foto de perfil (obligatoria)
      request.files.add(
        await http.MultipartFile.fromPath('foto_perfil', fotoPerfil.path),
      );

      // Foto del carro (opcional)
      if (fotoCarro != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_carro', fotoCarro.path),
        );
      }

      final streamedResponse = await request.send();
      final respuesta = await http.Response.fromStream(streamedResponse);

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
