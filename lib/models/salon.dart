/// Representa una fila de la tabla `salones` en Supabase.
class Salon {
  final String id;
  final String nombre;
  final String? piso;
  final String? bloque;

  Salon({required this.id, required this.nombre, this.piso, this.bloque});

  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? '',
      piso: map['piso'] as String?,
      bloque: map['bloque'] as String?,
    );
  }

  /// Subtítulo tipo "Piso 1 · Bloque A", solo con los datos disponibles.
  String? get ubicacion {
    final partes = [
      if (piso != null && piso!.trim().isNotEmpty) 'Piso ${piso!.trim()}',
      if (bloque != null && bloque!.trim().isNotEmpty) 'Bloque ${bloque!.trim()}',
    ];
    return partes.isEmpty ? null : partes.join(' · ');
  }
}
