import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/estado_equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/barra_estados.dart';
import '../widgets/equipo_card.dart';
import '../widgets/filtro_estados.dart';
import '../widgets/island_nav_bar.dart';
import '../widgets/nuevo_equipo_form.dart';
import 'detalle_equipo_screen.dart';
import 'tecnico_screen.dart';

/// Segundo nivel de la jerarquía de vistas: todos los computadores de
/// UN salón, con chips para filtrar por estado (Disponible/En uso/
/// Dañado/Mantenimiento). Reutiliza la MISMA isla de navegación inferior
/// que las demás vistas.
class SalonDetalleScreen extends StatefulWidget {
  final Salon salon;

  const SalonDetalleScreen({super.key, required this.salon});

  @override
  State<SalonDetalleScreen> createState() => _SalonDetalleScreenState();
}

class _SalonDetalleScreenState extends State<SalonDetalleScreen> {
  final _service = SupabaseService();
  late final Stream<List<Equipo>> _equiposStream;
  EstadoEquipo? _filtro; // null = "Todos"

  @override
  void initState() {
    super.initState();
    _equiposStream = _service.streamEquiposPorSalon(widget.salon.id);
  }

  String _slug(String nombre) {
    final digitos = RegExp(r'\d+').stringMatch(nombre);
    if (digitos != null) return digitos;
    final limpio = nombre.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    return limpio.isEmpty ? 'SALA' : limpio;
  }

  Future<void> _abrirFormularioNuevoEquipo(int totalActual) async {
    final sugerido =
        'PC-${_slug(widget.salon.nombre)}-${(totalActual + 1).toString().padLeft(2, '0')}';

    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => NuevoEquipoForm(
        salonId: widget.salon.id,
        codigoSugerido: sugerido,
      ),
    );
    if (creado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipo agregado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.salon.nombre),
        bottom: widget.salon.ubicacion != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(22),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.salon.ubicacion!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              )
            : null,
      ),
      body: StreamBuilder<List<Equipo>>(
        stream: _equiposStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final equipos = snapshot.data ?? [];
          final disponibles = equipos.where((e) => e.estado == EstadoEquipo.disponible).length;
          final enUso = equipos.where((e) => e.estado == EstadoEquipo.enUso).length;
          final danados = equipos.where((e) => e.estado == EstadoEquipo.danado).length;
          final mantenimiento = equipos.where((e) => e.estado == EstadoEquipo.mantenimiento).length;

          final equiposFiltrados =
              _filtro == null ? equipos : equipos.where((e) => e.estado == _filtro).toList();

          return Stack(
            children: [
              Column(
                children: [
                  if (equipos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: BarraEstados(
                        disponibles: disponibles,
                        enUso: enUso,
                        danados: danados,
                        mantenimiento: mantenimiento,
                      ),
                    ),
                  if (equipos.isNotEmpty)
                    FiltroEstados(
                      seleccionado: _filtro,
                      onCambiar: (nuevo) => setState(() => _filtro = nuevo),
                      total: equipos.length,
                      disponibles: disponibles,
                      enUso: enUso,
                      danados: danados,
                      mantenimiento: mantenimiento,
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: equipos.isEmpty
                        ? const Center(
                            child: Text(
                              'Este salón todavía no tiene computadores.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : equiposFiltrados.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay equipos con este estado.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 110),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: equiposFiltrados.length,
                                itemBuilder: (context, index) {
                                  final equipo = equiposFiltrados[index];
                                  return EquipoCard(
                                    equipo: equipo,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DetalleEquipoScreen(equipo: equipo),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),

              // Misma isla de navegación que las demás vistas.
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
                        activo: true,
                        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      IslandNavItem(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Registrar',
                        onTap: () => _abrirFormularioNuevoEquipo(equipos.length),
                      ),
                      IslandNavItem(
                        icon: Icons.build_rounded,
                        label: 'Técnico',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TecnicoScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
