import 'package:flutter/material.dart';
import '../models/estado_equipo.dart';
import '../theme/app_theme.dart';

/// Fila horizontal de chips para filtrar el grid de equipos por estado.
/// `null` en [seleccionado] representa "Todos".
class FiltroEstados extends StatelessWidget {
  final EstadoEquipo? seleccionado;
  final ValueChanged<EstadoEquipo?> onCambiar;
  final int total;
  final int disponibles;
  final int enUso;
  final int danados;
  final int mantenimiento;

  const FiltroEstados({
    super.key,
    required this.seleccionado,
    required this.onCambiar,
    required this.total,
    required this.disponibles,
    required this.enUso,
    required this.danados,
    required this.mantenimiento,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(label: 'Todos ($total)', activo: seleccionado == null, color: AppColors.primaryDark, onTap: () => onCambiar(null)),
          const SizedBox(width: 8),
          _Chip(
            label: '${EstadoEquipo.disponible.etiqueta} ($disponibles)',
            activo: seleccionado == EstadoEquipo.disponible,
            color: EstadoEquipo.disponible.color,
            onTap: () => onCambiar(EstadoEquipo.disponible),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '${EstadoEquipo.enUso.etiqueta} ($enUso)',
            activo: seleccionado == EstadoEquipo.enUso,
            color: EstadoEquipo.enUso.color,
            onTap: () => onCambiar(EstadoEquipo.enUso),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '${EstadoEquipo.danado.etiqueta} ($danados)',
            activo: seleccionado == EstadoEquipo.danado,
            color: EstadoEquipo.danado.color,
            onTap: () => onCambiar(EstadoEquipo.danado),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '${EstadoEquipo.mantenimiento.etiqueta} ($mantenimiento)',
            activo: seleccionado == EstadoEquipo.mantenimiento,
            color: EstadoEquipo.mantenimiento.color,
            onTap: () => onCambiar(EstadoEquipo.mantenimiento),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool activo;
  final Color color;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.activo, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? color.withValues(alpha: 0.9) : color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: activo ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
