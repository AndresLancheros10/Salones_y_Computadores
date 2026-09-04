import 'estado_equipo.dart';

class Equipo {
  final String id;
  final String codigo;
  final EstadoEquipo estado;
  final String? observacion;
  final String? marca;
  final String? numeroSerie;
  final String? salonId;
  final DateTime? updatedAt;

  Equipo({
    required this.id,
    required this.codigo,
    required this.estado,
    this.observacion,
    this.marca,
    this.numeroSerie,
    this.salonId,
    this.updatedAt,
  });

  /// Número secuencial del equipo, extraído del código (ej. "PC-317-05" -> 5).
  /// Se usa para mostrar "Computador #5" como en la vista técnica.
  int get numero {
    final match = RegExp(r'(\d+)$').firstMatch(codigo);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as String,
      codigo: map['codigo'] as String? ?? '',
      estado: EstadoEquipoInfo.desdeDb(map['estado_texto'] as String?),
      observacion: map['observacion'] as String?,
      marca: map['marca'] as String?,
      numeroSerie: map['numero_serie'] as String?,
      salonId: map['salon_id'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}
