import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Formulario táctil para diligenciar un nuevo salón: nombre y cantidad
/// de computadores. Al guardar, crea el salón en Supabase y genera
/// automáticamente un equipo por cada computador indicado (todos con
/// estado inicial "operativo", listos para ajustarse luego uno por uno).
///
/// Se muestra como un modal bottom sheet desde la vista de Salones.
class NuevoSalonForm extends StatefulWidget {
  const NuevoSalonForm({super.key});

  @override
  State<NuevoSalonForm> createState() => _NuevoSalonFormState();
}

class _NuevoSalonFormState extends State<NuevoSalonForm> {
  final _service = SupabaseService();
  final _nombreController = TextEditingController();
  int _cantidad = 30;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _cambiarCantidad(int delta) {
    setState(() {
      _cantidad = (_cantidad + delta).clamp(1, 100);
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del salón')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await _service.crearSalonConEquipos(nombre: nombre, cantidad: _cantidad);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el salón: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nuevo salón',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          const Text('Nombre del salón', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Ej: Salón 317'),
          ),
          const SizedBox(height: 20),
          const Text('¿Cuántos computadores tiene?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(icon: Icons.remove_rounded, onTap: () => _cambiarCantidad(-1)),
              SizedBox(
                width: 90,
                child: Text(
                  '$_cantidad',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              _StepButton(icon: Icons.add_rounded, onTap: () => _cambiarCantidad(1)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_guardando ? 'Creando...' : 'Crear salón y $_cantidad equipos'),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 48, // >= 44px, táctil
          height: 48,
          child: Icon(icon, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
