import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equipo.dart';
import '../models/estado_equipo.dart';
import '../models/salon.dart';

/// Encapsula toda la comunicación con Supabase (tablas `salones` y
/// `equipos`). Mantener esta lógica separada de la UI facilita las
/// pruebas y el mantenimiento (principio de responsabilidad única).
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------------------------------------------------
  // SALONES
  // ---------------------------------------------------------------------

  /// Stream en tiempo real de todos los salones, ordenados por nombre.
  Stream<List<Salon>> streamSalones() {
    return _client
        .from('salones')
        .stream(primaryKey: ['id'])
        .order('nombre', ascending: true)
        .map((rows) => rows.map((row) => Salon.fromMap(row)).toList());
  }

  /// Crea un salón nuevo y genera automáticamente `cantidad` equipos
  /// asociados a él (todos con estado inicial "disponible"). Esto es lo
  /// que dispara el formulario "Nuevo salón" de la app.
  Future<void> crearSalonConEquipos({
    required String nombre,
    required int cantidad,
    String? piso,
    String? bloque,
  }) async {
    final salonInsertado = await _client
        .from('salones')
        .insert({
          'nombre': nombre,
          if (piso != null && piso.trim().isNotEmpty) 'piso': piso.trim(),
          if (bloque != null && bloque.trim().isNotEmpty) 'bloque': bloque.trim(),
        })
        .select()
        .single();
    final salonId = salonInsertado['id'] as String;

    if (cantidad <= 0) return;

    final prefijo = _codigoPrefijo(nombre);
    final nuevosEquipos = List.generate(
      cantidad,
      (i) => {
        'codigo': 'PC-$prefijo-${(i + 1).toString().padLeft(2, '0')}',
        'estado_texto': EstadoEquipo.disponible.valorDb,
        'salon_id': salonId,
      },
    );

    await _client.from('equipos').insert(nuevosEquipos);
  }

  /// Elimina un salón. Los equipos asociados se eliminan en cascada
  /// (ON DELETE CASCADE definido en sql/schema.sql).
  Future<void> eliminarSalon(String salonId) async {
    await _client.from('salones').delete().eq('id', salonId);
  }

  /// Genera un prefijo corto y legible a partir del nombre del salón,
  /// usado para armar códigos de equipo tipo "PC-317-01".
  /// Ej: "Salón 317" -> "317" · "Lab Sistemas" -> "LABSISTEMAS"
  String _codigoPrefijo(String nombre) {
    final digitos = RegExp(r'\d+').stringMatch(nombre);
    if (digitos != null) return digitos;
    final limpio = nombre.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    return limpio.isEmpty ? 'SALA' : limpio;
  }

  // ---------------------------------------------------------------------
  // EQUIPOS
  // ---------------------------------------------------------------------

  /// Stream en tiempo real de TODOS los equipos, ordenados por código.
  /// Se usa en la vista de Salones para calcular el resumen de cada
  /// salón, y en la Vista Técnica para listar los que necesitan atención.
  Stream<List<Equipo>> streamEquipos() {
    return _client
        .from('equipos')
        .stream(primaryKey: ['id'])
        .order('codigo', ascending: true)
        .map((rows) => rows.map((row) => Equipo.fromMap(row)).toList());
  }

  /// Stream en tiempo real de los equipos de UN salón específico.
  Stream<List<Equipo>> streamEquiposPorSalon(String salonId) {
    return _client
        .from('equipos')
        .stream(primaryKey: ['id'])
        .eq('salon_id', salonId)
        .order('codigo', ascending: true)
        .map((rows) => rows.map((row) => Equipo.fromMap(row)).toList());
  }

  /// Actualiza el estado (uno de los 4 posibles), la observación, marca
  /// y número de serie de un equipo. Todos los campos son opcionales
  /// excepto el estado: si no se pasan marca/numeroSerie/observación,
  /// se guardan como null (se limpian).
  Future<void> actualizarEquipo({
    required String id,
    required EstadoEquipo estado,
    String? observacion,
    String? marca,
    String? numeroSerie,
  }) async {
    await _client.from('equipos').update({
      'estado_texto': estado.valorDb,
      'observacion': observacion,
      'marca': marca,
      'numero_serie': numeroSerie,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Actualiza SOLO la observación de un equipo (usado desde la Vista
  /// Técnica, donde se edita la nota sin abrir el detalle completo).
  Future<void> actualizarObservacion({
    required String id,
    required String? observacion,
  }) async {
    await _client.from('equipos').update({
      'observacion': observacion,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Crea un nuevo equipo dentro de un salón ya existente.
  Future<void> crearEquipo({
    required String codigo,
    required String salonId,
    String? marca,
    String? numeroSerie,
  }) async {
    await _client.from('equipos').insert({
      'codigo': codigo,
      'estado_texto': EstadoEquipo.disponible.valorDb,
      'salon_id': salonId,
      if (marca != null && marca.trim().isNotEmpty) 'marca': marca.trim(),
      if (numeroSerie != null && numeroSerie.trim().isNotEmpty) 'numero_serie': numeroSerie.trim(),
    });
  }

  /// Elimina un equipo individual (por si un salón se queda sin un PC).
  Future<void> eliminarEquipo(String equipoId) async {
    await _client.from('equipos').delete().eq('id', equipoId);
  }
}
