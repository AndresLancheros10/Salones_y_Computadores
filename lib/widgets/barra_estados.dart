import 'package:flutter/material.dart';
import '../models/estado_equipo.dart';

/// Barra de progreso apilada mostrando la proporción de cada estado.
/// Se usa tanto en la tarjeta de salón como en el detalle de un salón.
class BarraEstados extends StatelessWidget {
  final int disponibles;
  final int enUso;
  final int danados;
  final int mantenimiento;

  const BarraEstados({
    super.key,
    required this.disponibles,
    required this.enUso,
    required this.danados,
    required this.mantenimiento,
  });

  @override
  Widget build(BuildContext context) {
    final total = disponibles + enUso + danados + mantenimiento;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (disponibles > 0)
              Expanded(flex: disponibles, child: Container(color: EstadoEquipo.disponible.color)),
            if (enUso > 0) Expanded(flex: enUso, child: Container(color: EstadoEquipo.enUso.color)),
            if (danados > 0) Expanded(flex: danados, child: Container(color: EstadoEquipo.danado.color)),
            if (mantenimiento > 0)
              Expanded(flex: mantenimiento, child: Container(color: EstadoEquipo.mantenimiento.color)),
          ],
        ),
      ),
    );
  }
}
