import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'salon_detalle_screen.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final _service = SupabaseService();
  late final Stream<List<Salon>> _salonesStream;
  late final Stream<List<Equipo>> _equiposStream;

  @override
  void initState() {
    super.initState();
    _salonesStream = _service.streamSalones();
    _equiposStream = _service.streamEquipos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas generales')),
      body: StreamBuilder<List<Salon>>(
        stream: _salonesStream,
        builder: (context, salonesSnap) {
          final salones = salonesSnap.data ?? [];

          return StreamBuilder<List<Equipo>>(
            stream: _equiposStream,
            builder: (context, equiposSnap) {
              if (salonesSnap.connectionState == ConnectionState.waiting ||
                  equiposSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final equipos = equiposSnap.data ?? [];
              final totalEquipos = equipos.length;
              final operativos = equipos.where((e) => e.estado).length;
              final fallas = totalEquipos - operativos;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Salones',
                          value: '${salones.length}',
                          color: AppColors.primaryDark,
                          icon: Icons.meeting_room_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Equipos',
                          value: '$totalEquipos',
                          color: AppColors.accent,
                          icon: Icons.computer_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Operativos',
                          value: '$operativos',
                          color: AppColors.operativo,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Con falla',
                          value: '$fallas',
                          color: AppColors.falla,
                          icon: Icons.error_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Desglose por salón',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  if (salones.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Todavía no hay salones registrados.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...salones.map((salon) {
                      final equiposDelSalon = equipos.where((e) => e.salonId == salon.id).toList();
                      final opSalon = equiposDelSalon.where((e) => e.estado).length;
                      final fallasSalon = equiposDelSalon.length - opSalon;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => SalonDetalleScreen(salon: salon)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      salon.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  _MiniBadge(color: AppColors.operativo, label: '$opSalon'),
                                  const SizedBox(width: 8),
                                  _MiniBadge(color: AppColors.falla, label: '$fallasSalon'),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final Color color;
  final String label;
  const _MiniBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}