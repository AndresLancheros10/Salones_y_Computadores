import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Formulario táctil para actualizar el estado de un equipo y dejar
/// observaciones para el técnico que vaya a repararlo.
///
/// Ergonomía aplicada:
/// - Todos los controles interactivos (switch, botón) tienen un alto
///   mínimo de 44px, tamaño recomendado para pulsación con el dedo.
/// - El botón de guardar (acción principal) está anclado en la parte
///   inferior de la pantalla (Regla del Pulgar), no en el AppBar.
class DetalleEquipoScreen extends StatefulWidget {
  final Equipo equipo;

  const DetalleEquipoScreen({super.key, required this.equipo});

  @override
  State<DetalleEquipoScreen> createState() => _DetalleEquipoScreenState();
}

class _DetalleEquipoScreenState extends State<DetalleEquipoScreen> {
  final SupabaseService _service = SupabaseService();
  late bool _estado;
  late TextEditingController _observacionController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _estado = widget.equipo.estado;
    _observacionController = TextEditingController(text: widget.equipo.observacion ?? '');
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await _service.actualizarEstado(
        id: widget.equipo.id,
        estado: _estado,
        observacion: _observacionController.text.trim().isEmpty
            ? null
            : _observacionController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _estado ? AppColors.operativo : AppColors.falla;
    final Color colorFondo = _estado ? AppColors.operativoBg : AppColors.fallaBg;

    return Scaffold(
      appBar: AppBar(title: Text(widget.equipo.codigo)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado con semáforo grande, fácil de leer a distancia,
              // en tonos pastel en vez de colores saturados.
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      _estado ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: color,
                      size: 56,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _estado ? 'OPERATIVO' : 'FALLA',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Switch táctil (>= 44px de alto) para cambiar el estado.
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.islandShadow, blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text('Marcar como operativo', style: TextStyle(color: AppColors.textPrimary)),
                  value: _estado,
                  onChanged: (v) => setState(() => _estado = v),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Observación para el técnico',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              // Campo de texto con alto mínimo de 44px, fácil de pulsar.
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
      // Botón de acción principal anclado abajo (Regla del Pulgar).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52, // >= 44px
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            ),
          ),
        ),
      ),
    );
  }
}
