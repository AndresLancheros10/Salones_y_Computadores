import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Formulario táctil para agregar un computador individual a un salón
/// ya existente (por ejemplo, si llega un PC nuevo a mitad de semestre).
/// Se muestra como un modal bottom sheet desde la vista de detalle
/// de un salón.
class NuevoEquipoForm extends StatefulWidget {
  final String salonId;
  final String codigoSugerido;

  const NuevoEquipoForm({
    super.key,
    required this.salonId,
    required this.codigoSugerido,
  });

  @override
  State<NuevoEquipoForm> createState() => _NuevoEquipoFormState();
}

class _NuevoEquipoFormState extends State<NuevoEquipoForm> {
  final _service = SupabaseService();
  late final TextEditingController _codigoController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.codigoSugerido);
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el código del equipo')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await _service.crearEquipo(codigo: codigo, salonId: widget.salonId);
      if (mounted) Navigator.of(context).pop(true);
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
            'Agregar computador',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          const Text('Código del equipo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _codigoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Ej: PC-317-31'),
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
            label: Text(_guardando ? 'Guardando...' : 'Agregar equipo'),
          ),
        ],
      ),
    );
  }
}
