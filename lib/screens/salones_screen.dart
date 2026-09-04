import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/island_nav_bar.dart';
import '../widgets/nuevo_salon_form.dart';
import '../widgets/salon_card.dart';
import 'estadisticas_screen.dart';
import 'salon_detalle_screen.dart';

class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  final _service = SupabaseService();
  late final Stream<List<Salon>> _salonesStream;
  late final Stream<List<Equipo>> _equiposStream;

  @override
  void initState() {
    super.initState();
    _salonesStream = _service.streamSalones();
    _equiposStream = _service.streamEquipos();
  }

  Future<void> _abrirFormularioNuevoSalon() async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NuevoSalonForm(),
    );
    if (creado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salón creado correctamente')),
      );
    }
  }

  Future<void> _eliminarSalon(Salon salon) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿Eliminar ${salon.nombre}?'),
        content: const Text('Se eliminarán también todos sus computadores registrados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.eliminarSalon(salon.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salones · Monitor de equipos')),
      body: Stack(
        children: [
          StreamBuilder<List<Salon>>(
            stream: _salonesStream,
            builder: (context, salonesSnap) {
              if (salonesSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (salonesSnap.hasError) {
                return _ErrorState(message: salonesSnap.error.toString());
              }
              final salones = salonesSnap.data ?? [];

              return StreamBuilder<List<Equipo>>(
                stream: _equiposStream,
                builder: (context, equiposSnap) {
                  final equipos = equiposSnap.data ?? [];

                  if (salones.isEmpty) {
                    return _EstadoVacio(onAgregar: _abrirFormularioNuevoSalon);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    itemCount: salones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final salon = salones[index];
                      final equiposDelSalon =
                          equipos.where((e) => e.salonId == salon.id).toList();
                      return SalonCard(
                        salon: salon,
                        equipos: equiposDelSalon,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SalonDetalleScreen(salon: salon),
                          ),
                        ),
                        onDelete: () => _eliminarSalon(salon),
                      );
                    },
                  );
                },
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: IslandNavBar(
                items: [
                  IslandNavItem(
                    icon: Icons.meeting_room_rounded,
                    label: 'Salones',
                    onTap: () {},
                  ),
                  IslandNavItem(
                    icon: Icons.insights_rounded,
                    label: 'Estadísticas',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
                    ),
                  ),
                  IslandNavItem(
                    icon: Icons.add_rounded,
                    label: 'Nuevo',
                    destacado: true,
                    onTap: _abrirFormularioNuevoSalon,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onAgregar;
  const _EstadoVacio({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.meeting_room_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'Todavía no hay salones registrados.\nAgrega el primero para empezar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar salón'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No fue posible conectar con Supabase.\n$message',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}