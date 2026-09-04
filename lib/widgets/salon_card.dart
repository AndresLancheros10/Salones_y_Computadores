import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/estado_equipo.dart';
import '../models/salon.dart';
import '../theme/app_theme.dart';
import 'barra_estados.dart';

/// Tarjeta resumen de un salón: nombre, ubicación (piso/bloque si existen),
/// barra de progreso apilada con los 4 estados, conteos y una alerta si
/// hay equipos que requieren atención técnica (dañados o en mantenimiento).
class SalonCard extends StatelessWidget {
  final Salon salon;
  final List<Equipo> equipos;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SalonCard({
    super.key,
    required this.salon,
    required this.equipos,
    required this.onTap,
    required this.onDelete,
  });

  int _contar(EstadoEquipo estado) => equipos.where((e) => e.estado == estado).length;

  @override
  Widget build(BuildContext context) {
    final total = equipos.length;
    final disponibles = _contar(EstadoEquipo.disponible);
    final enUso = _contar(EstadoEquipo.enUso);
    final danados = _contar(EstadoEquipo.danado);
    final mantenimiento = _contar(EstadoEquipo.mantenimiento);
    final requierenAtencion = danados + mantenimiento;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: AppColors.islandShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        if (salon.ubicacion != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              salon.ubicacion!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$total PCs',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                    tooltip: 'Eliminar salón',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra apilada: proporción visual de cada estado.
              if (total > 0)
                BarraEstados(
                  disponibles: disponibles,
                  enUso: enUso,
                  danados: danados,
                  mantenimiento: mantenimiento,
                ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _Leyenda(color: EstadoEquipo.disponible.color, label: '$disponibles Disponible'),
                  _Leyenda(color: EstadoEquipo.enUso.color, label: '$enUso En uso'),
                  _Leyenda(color: EstadoEquipo.danado.color, label: '$danados Dañado'),
                  _Leyenda(color: EstadoEquipo.mantenimiento.color, label: '$mantenimiento Mantenimiento'),
                ],
              ),

              if (requierenAtencion > 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.fallaBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.falla, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$requierenAtencion equipo${requierenAtencion == 1 ? '' : 's'} requiere${requierenAtencion == 1 ? '' : 'n'} atención técnica',
                          style: TextStyle(color: AppColors.falla, fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ver detalle', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13)),
                    Icon(Icons.chevron_right, color: AppColors.primaryDark, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String label;
  const _Leyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
