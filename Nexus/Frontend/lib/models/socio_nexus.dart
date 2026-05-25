/// Modelo de datos del perfil de Socio Nexus (conductor).
class SocioNexus {
  final int? id;
  final String nombreCompleto;
  final String correo;
  final String? modeloCarro;
  final String? placas;
  final String? fotoPerfil;
  final String? fotoCarro;
  final double calificacion;

  const SocioNexus({
    this.id,
    required this.nombreCompleto,
    required this.correo,
    this.modeloCarro,
    this.placas,
    this.fotoPerfil,
    this.fotoCarro,
    this.calificacion = 5.0,
  });

  factory SocioNexus.fromJson(Map<String, dynamic> json) => SocioNexus(
        id: json['id'] as int?,
        nombreCompleto: json['nombre_completo'] as String? ?? '',
        correo: json['correo'] as String? ?? '',
        modeloCarro: json['modelo_carro'] as String?,
        placas: json['placas'] as String?,
        fotoPerfil: json['foto_perfil'] as String?,
        fotoCarro: json['foto_carro'] as String?,
        calificacion: (json['calificacion'] as num?)?.toDouble() ?? 5.0,
      );

  @override
  String toString() =>
      'SocioNexus(nombre: $nombreCompleto, correo: $correo, vehiculo: $modeloCarro)';
}
