import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/estado_equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Vista técnica: lista todos los computadores que requieren atención
/// (Dañados o en Mantenimiento) en TODOS los salones, para que el
/// técnico pueda revisar y anotar observaciones sin tener que entrar
/// salón por salón.
class TecnicoScreen extends StatefulWidget {
  const TecnicoScreen({super.key});

  @override
  State<TecnicoScreen> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoScreen> {
  final _service = SupabaseService();
  late final Stream<List<Equipo>> _equiposStream;
  late final Stream<List<Salon>> _salonesStream;

  @override
  void initState() {
    super.initState();
    _equiposStream = _service.streamEquipos();
    _salonesStream = _service.streamSalones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista técnica')),
      body: StreamBuilder<List<Salon>>(
        stream: _salonesStream,
        builder: (context, salonesSnap) {
          final salonesPorId = {for (final s in (salonesSnap.data ?? <Salon>[])) s.id: s};

          return StreamBuilder<List<Equipo>>(
            stream: _equiposStream,
            builder: (context, equiposSnap) {
              if (equiposSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (equiposSnap.hasError) {
                return Center(child: Text('Error: ${equiposSnap.error}'));
              }

              final todos = equiposSnap.data ?? [];
              final pendientes = todos.where((e) => e.estado.requiereAtencion).toList();
              final sinObservacion = pendientes.where((e) => (e.observacion ?? '').trim().isEmpty).toList();
              final conObservacion = pendientes.where((e) => (e.observacion ?? '').trim().isNotEmpty).toList();

              if (pendientes.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt_rounded, size: 56, color: AppColors.operativo),
                        SizedBox(height: 12),
                        Text(
                          '¡Todo en orden!\nNingún equipo requiere atención técnica.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  const Text(
                    'ÓRDENES DE TRABAJO',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Chip(label: '${pendientes.length} equipos', color: AppColors.falla),
                      const SizedBox(width: 8),
                      _Chip(label: '${conObservacion.length} con observaciones', color: AppColors.primaryDark),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (sinObservacion.isNotEmpty) ...[
                    Text('SIN OBSERVACIONES (${sinObservacion.length})',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    ...sinObservacion.map((e) => _EquipoTecnicoCard(equipo: e, salon: salonesPorId[e.salonId], servicio: _service)),
                    const SizedBox(height: 20),
                  ],

                  if (conObservacion.isNotEmpty) ...[
                    Text('CON OBSERVACIONES (${conObservacion.length})',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    ...conObservacion.map((e) => _EquipoTecnicoCard(equipo: e, salon: salonesPorId[e.salonId], servicio: _service)),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
    );
  }
}

/// Tarjeta de un equipo pendiente, con campo de observación editable
/// directamente ahí (sin tener que abrir el detalle completo).
class _EquipoTecnicoCard extends StatefulWidget {
  final Equipo equipo;
  final Salon? salon;
  final SupabaseService servicio;

  const _EquipoTecnicoCard({required this.equipo, required this.salon, required this.servicio});

  @override
  State<_EquipoTecnicoCard> createState() => _EquipoTecnicoCardState();
}

class _EquipoTecnicoCardState extends State<_EquipoTecnicoCard> {
  late final TextEditingController _controller;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.equipo.observacion ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await widget.servicio.actualizarObservacion(
        id: widget.equipo.id,
        observacion: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Observación guardada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipo = widget.equipo;
    final color = equipo.estado.color;
    final colorFondo = equipo.estado.colorFondo;
    final subtitulo = [
      if ((equipo.marca ?? '').trim().isNotEmpty) equipo.marca!.trim(),
      if ((equipo.numeroSerie ?? '').trim().isNotEmpty) equipo.numeroSerie!.trim(),
    ].join(' · ');
    final ubicacion = [
      if (widget.salon != null) widget.salon!.nombre,
      if (widget.salon?.ubicacion != null) widget.salon!.ubicacion!,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: AppColors.islandShadow, blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.computer_rounded, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Computador #${equipo.numero}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary)),
                    if (subtitulo.isNotEmpty)
                      Text(subtitulo, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(10)),
                child: Text(equipo.estado.etiqueta, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (ubicacion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(ubicacion, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Sin observaciones registradas',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_rounded, size: 20, color: AppColors.primaryDark),
                tooltip: 'Guardar observación',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
