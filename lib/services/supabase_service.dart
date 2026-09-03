import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equipo.dart';

/// Encapsula toda la comunicación con Supabase para la tabla `equipos`.
/// Mantener esta lógica separada de la UI facilita las pruebas y el
/// mantenimiento (principio de responsabilidad única).
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Stream en tiempo real de todos los equipos, ordenados por código.
  /// Cada vez que otro usuario/dispositivo actualiza una fila en la tabla
  /// `equipos`, Supabase Realtime empuja el cambio y este Stream emite
  /// la lista completa actualizada (CDC: Change Data Capture).
  Stream<List<Equipo>> streamEquipos() {
    return _client
        .from('equipos')
        .stream(primaryKey: ['id'])
        .order('codigo', ascending: true)
        .map((rows) => rows.map((row) => Equipo.fromMap(row)).toList());
  }

  /// Actualiza el estado (operativo/falla) y la observación de un equipo.
  Future<void> actualizarEstado({
    required String id,
    required bool estado,
    String? observacion,
  }) async {
    await _client.from('equipos').update({
      'estado': estado,
      'observacion': observacion,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Crea un nuevo equipo dentro de un salón.
  Future<void> crearEquipo({
    required String codigo,
    required String salonId,
  }) async {
    await _client.from('equipos').insert({
      'codigo': codigo,
      'estado': true,
      'salon_id': salonId,
    });
  }
}
