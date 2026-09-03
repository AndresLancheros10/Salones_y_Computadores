import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/salon.dart';
import '../theme/app_theme.dart';

/// Tarjeta resumen de un salón: nombre, total de equipos y mini semáforo
/// (operativos vs. con falla), calculado a partir de la lista de equipos
/// de ese salón. Área táctil amplia para cumplir ergonomía móvil.
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

  @override
  Widget build(BuildContext context) {
    final total = equipos.length;
    final operativos = equipos.where((e) => e.estado).length;
    final fallas = total - operativos;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: AppColors.islandShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.meeting_room_rounded, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniChip(color: AppColors.operativo, label: '$operativos'),
                        const SizedBox(width: 8),
                        _MiniChip(color: AppColors.falla, label: '$fallas'),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '· $total equipos',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                tooltip: 'Eliminar salón',
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final Color color;
  final String label;
  const _MiniChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
