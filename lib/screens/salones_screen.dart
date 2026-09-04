import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/island_nav_bar.dart';
import '../widgets/salon_card.dart';
import 'nuevo_salon_screen.dart';
import 'salon_detalle_screen.dart';
import 'tecnico_screen.dart';
import '../models/estado_equipo.dart';

/// Pantalla raíz de la aplicación.
///
/// Muestra todos los salones registrados, un resumen general
/// de equipos y un buscador.
class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  final SupabaseService _service = SupabaseService();

  late final Stream<List<Salon>> _salonesStream;
  late final Stream<List<Equipo>> _equiposStream;

  String _busqueda = '';

  @override
  void initState() {
    super.initState();

    _salonesStream = _service.streamSalones();
    _equiposStream = _service.streamEquipos();
  }

  Future<void> _abrirNuevoSalon() async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const NuevoSalonScreen(),
      ),
    );

    if (creado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salón creado correctamente'),
        ),
      );
    }
  }

  Future<void> _eliminarSalon(Salon salon) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('¿Eliminar ${salon.nombre}?'),
          content: const Text(
            'Se eliminarán también todos sus computadores registrados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _service.eliminarSalon(salon.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Equipos'),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Salon>>(
            stream: _salonesStream,
            builder: (context, salonesSnap) {
              if (salonesSnap.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (salonesSnap.hasError) {
                return _ErrorState(
                  message: salonesSnap.error.toString(),
                );
              }

              final salones = salonesSnap.data ?? <Salon>[];

              return StreamBuilder<List<Equipo>>(
                stream: _equiposStream,
                builder: (context, equiposSnap) {
                  final equipos =
                      equiposSnap.data ?? <Equipo>[];

                  // Equipos que necesitan atención técnica:
                  // dañados o en mantenimiento.
                  final requierenAtencion = equipos
                      .where(
                        (equipo) =>
                            equipo.estado.requiereAtencion,
                      )
                      .length;

                  final textoBusqueda =
                      _busqueda.trim().toLowerCase();

                  final salonesFiltrados =
                      textoBusqueda.isEmpty
                          ? salones
                          : salones
                              .where(
                                (salon) => salon.nombre
                                    .toLowerCase()
                                    .contains(textoBusqueda),
                              )
                              .toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _StatChip(
                                    label:
                                        '${salones.length} salones',
                                    color:
                                        AppColors.primaryDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    label:
                                        '${equipos.length} computadores',
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    label:
                                        '$requierenAtencion con fallos',
                                    color: AppColors.falla,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              onChanged: (valor) {
                                setState(() {
                                  _busqueda = valor;
                                });
                              },
                              decoration:
                                  const InputDecoration(
                                hintText: 'Buscar salón...',
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color:
                                      AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: salones.isEmpty
                            ? _EstadoVacio(
                                onAgregar:
                                    _abrirNuevoSalon,
                              )
                            : salonesFiltrados.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(24),
                                      child: Text(
                                        'No se encontró ningún salón con ese nombre.',
                                        textAlign:
                                            TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors
                                              .textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      110,
                                    ),
                                    itemCount:
                                        salonesFiltrados.length,
                                    separatorBuilder:
                                        (_, __) =>
                                            const SizedBox(
                                      height: 12,
                                    ),
                                    itemBuilder:
                                        (context, index) {
                                      final salon =
                                          salonesFiltrados[
                                              index];

                                      final equiposDelSalon =
                                          equipos
                                              .where(
                                                (equipo) =>
                                                    equipo.salonId ==
                                                    salon.id,
                                              )
                                              .toList();

                                      return SalonCard(
                                        salon: salon,
                                        equipos:
                                            equiposDelSalon,
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SalonDetalleScreen(
                                                salon: salon,
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () =>
                                            _eliminarSalon(
                                          salon,
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Barra de navegación flotante.
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: StreamBuilder<List<Equipo>>(
                stream: _equiposStream,
                builder: (context, snapshot) {
                  final equipos =
                      snapshot.data ?? <Equipo>[];

                  final requierenAtencion = equipos
                      .where(
                        (equipo) =>
                            equipo.estado.requiereAtencion,
                      )
                      .length;

                  return IslandNavBar(
                    items: [
                      IslandNavItem(
                        icon: Icons.meeting_room_rounded,
                        label: 'Salones',
                        activo: true,
                        onTap: () {},
                      ),
                      IslandNavItem(
                        icon:
                            Icons.add_circle_outline_rounded,
                        label: 'Registrar',
                        onTap: _abrirNuevoSalon,
                      ),
                      IslandNavItem(
                        icon: Icons.build_rounded,
                        label: 'Técnico',
                        badge: requierenAtencion,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TecnicoScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onAgregar;

  const _EstadoVacio({
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Todavía no hay salones registrados.\n'
              'Agrega el primero para empezar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
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

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
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