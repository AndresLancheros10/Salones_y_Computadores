import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/salon.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/equipo_card.dart';
import '../widgets/island_nav_bar.dart';
import '../widgets/nuevo_equipo_form.dart';
import '../widgets/resumen_bar.dart';
import 'detalle_equipo_screen.dart';
import 'estadisticas_screen.dart';

class SalonDetalleScreen extends StatefulWidget {
  final Salon salon;

  const SalonDetalleScreen({super.key, required this.salon});

  @override
  State<SalonDetalleScreen> createState() => _SalonDetalleScreenState();
}

class _SalonDetalleScreenState extends State<SalonDetalleScreen> {
  final _service = SupabaseService();
  late final Stream<List<Equipo>> _equiposStream;

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
      appBar: AppBar(title: Text(widget.salon.nombre)),
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
          final operativos = equipos.where((e) => e.estado).length;

          return Stack(
            children: [
              Column(
                children: [
                  ResumenBar(total: equipos.length, operativos: operativos),
                  Expanded(
                    child: equipos.isEmpty
                        ? const Center(
                            child: Text(
                              'Este salón todavía no tiene computadores.',
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
                            itemCount: equipos.length,
                            itemBuilder: (context, index) {
                              final equipo = equipos[index];
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: IslandNavBar(
                    items: [
                      IslandNavItem(
                        icon: Icons.home_rounded,
                        label: 'Salones',
                        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
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
                        label: 'Equipo',
                        destacado: true,
                        onTap: () => _abrirFormularioNuevoEquipo(equipos.length),
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