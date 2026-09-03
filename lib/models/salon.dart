/// Representa una fila de la tabla `salones` en Supabase.
class Salon {
  final String id;
  final String nombre;

  Salon({required this.id, required this.nombre});

  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? '',
    );
  }
}
