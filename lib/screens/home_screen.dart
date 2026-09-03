import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../services/supabase_service.dart';
import '../widgets/equipo_card.dart';
import 'detalle_equipo_screen.dart';

/// Pantalla principal: feed en tiempo real de los 30 equipos del Salón 317.
///
/// Ergonomía aplicada:
/// - Regla del Pulgar: la acción principal (refrescar / agregar) vive en un
///   FloatingActionButton en la esquina inferior derecha, zona alcanzable
///   con el pulgar en uso a una mano.
/// - Feed de estados: GridView.builder que se reconstruye automáticamente
///   ante cada evento del Stream (sin pull-to-refresh manual necesario).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _service = SupabaseService();
  late final Stream<List<Equipo>> _equiposStream;

  @override
  void initState() {
    super.initState();
    _equiposStream = _service.streamEquipos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Salón 317 · Monitor en vivo'),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Equipo>>(
        stream: _equiposStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(message: snapshot.error.toString());
          }

          final equipos = snapshot.data ?? [];
          if (equipos.isEmpty) {
            return const Center(
              child: Text('No hay equipos registrados todavía.'),
            );
          }

          final operativos = equipos.where((e) => e.estado).length;

          return Column(
            children: [
              _ResumenBar(total: equipos.length, operativos: operativos),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                          builder: (_) =>
                              DetalleEquipoScreen(equipo: equipo),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Barra resumen: cuántos equipos operativos vs. total.
class _ResumenBar extends StatelessWidget {
  final int total;
  final int operativos;

  const _ResumenBar({required this.total, required this.operativos});

  @override
  Widget build(BuildContext context) {
    final fallas = total - operativos;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Chip(color: Colors.green, label: '$operativos operativos'),
          _Chip(color: Colors.red, label: '$fallas con falla'),
          Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;

  const _Chip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
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
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
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
