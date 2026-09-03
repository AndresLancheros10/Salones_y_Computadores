class Equipo {
  final String id;
  final String codigo;
  final bool estado; // true = operativo, false = falla
  final String? observacion;
  final String? salonId;
  final DateTime? updatedAt;

  Equipo({
    required this.id,
    required this.codigo,
    required this.estado,
    this.observacion,
    this.salonId,
    this.updatedAt,
  });

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as String,
      codigo: map['codigo'] as String? ?? '',
      estado: map['estado'] as bool? ?? true,
      observacion: map['observacion'] as String?,
      salonId: map['salon_id'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}
