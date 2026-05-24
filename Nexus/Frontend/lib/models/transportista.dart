/// Modelo de datos del perfil de transportista.
class Transportista {
  final int? id;
  final String nombreCompleto;
  final String modeloVehiculo;
  final String placas;
  final String tipoUsuario;

  const Transportista({
    this.id,
    required this.nombreCompleto,
    required this.modeloVehiculo,
    required this.placas,
    this.tipoUsuario = 'transportista',
  });

  Map<String, dynamic> toJson() => {
        'nombre_completo': nombreCompleto,
        'modelo_vehiculo': modeloVehiculo,
        'placas': placas,
        'tipo_usuario': tipoUsuario,
      };

  factory Transportista.fromJson(Map<String, dynamic> json) => Transportista(
        id: json['id'] as int?,
        nombreCompleto: json['nombre_completo'] as String? ?? '',
        modeloVehiculo: json['modelo_vehiculo'] as String? ?? '',
        placas: json['placas'] as String? ?? '',
        tipoUsuario: json['tipo_usuario'] as String? ?? 'transportista',
      );

  @override
  String toString() =>
      'Transportista(nombre: $nombreCompleto, vehiculo: $modeloVehiculo, placas: $placas)';
}
