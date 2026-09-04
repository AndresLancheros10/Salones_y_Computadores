import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/estado_equipo.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Formulario táctil para actualizar el estado de un equipo (uno de los
/// 4 posibles), su marca, número de serie, y dejar observaciones para
/// el técnico que vaya a repararlo.
class DetalleEquipoScreen extends StatefulWidget {
  final Equipo equipo;

  const DetalleEquipoScreen({super.key, required this.equipo});

  @override
  State<DetalleEquipoScreen> createState() => _DetalleEquipoScreenState();
}

class _DetalleEquipoScreenState extends State<DetalleEquipoScreen> {
  final SupabaseService _service = SupabaseService();
  late EstadoEquipo _estado;
  late TextEditingController _observacionController;
  late TextEditingController _marcaController;
  late TextEditingController _numeroSerieController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _estado = widget.equipo.estado;
    _observacionController = TextEditingController(text: widget.equipo.observacion ?? '');
    _marcaController = TextEditingController(text: widget.equipo.marca ?? '');
    _numeroSerieController = TextEditingController(text: widget.equipo.numeroSerie ?? '');
  }

  @override
  void dispose() {
    _observacionController.dispose();
    _marcaController.dispose();
    _numeroSerieController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await _service.actualizarEquipo(
        id: widget.equipo.id,
        estado: _estado,
        observacion: _observacionController.text.trim().isEmpty ? null : _observacionController.text.trim(),
        marca: _marcaController.text.trim().isEmpty ? null : _marcaController.text.trim(),
        numeroSerie: _numeroSerieController.text.trim().isEmpty ? null : _numeroSerieController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _estado.color;
    final colorFondo = _estado.colorFondo;

    return Scaffold(
      appBar: AppBar(title: Text('Computador #${widget.equipo.numero}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado actual, grande y fácil de leer.
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(_estado.icono, color: color, size: 52),
                    const SizedBox(height: 8),
                    Text(
                      _estado.etiqueta.toUpperCase(),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Cambiar estado', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: EstadoEquipo.values.map((estado) {
                  final activo = estado == _estado;
                  return Material(
                    color: activo ? estado.color : estado.colorFondo,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _estado = estado),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(estado.icono, size: 18, color: activo ? Colors.white : estado.color),
                            const SizedBox(width: 6),
                            Text(
                              estado.etiqueta,
                              style: TextStyle(
                                color: activo ? Colors.white : estado.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('Marca', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _marcaController,
                decoration: const InputDecoration(hintText: 'Ej: Acer, Asus, HP...'),
              ),

              const SizedBox(height: 20),
              const Text('Número de serie', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _numeroSerieController,
                decoration: const InputDecoration(hintText: 'Ej: SN-2025-0137'),
              ),

              const SizedBox(height: 20),
              const Text('Observación para el técnico', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _observacionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Ej: Mouse dañado, no enciende, pantalla con líneas...',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            ),
          ),
        ),
      ),
    );
  }
}
