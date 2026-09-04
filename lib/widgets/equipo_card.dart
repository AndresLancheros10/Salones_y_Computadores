import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../theme/app_theme.dart';

class EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const EquipoCard({super.key, required this.equipo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = equipo.estado ? AppColors.operativo : AppColors.falla;
    final Color colorFondo = equipo.estado ? AppColors.operativoBg : AppColors.fallaBg;
    final IconData icono = equipo.estado ? Icons.check_circle_rounded : Icons.error_rounded;
    final bool tieneObservacion = (equipo.observacion ?? '').trim().isNotEmpty;

    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(icono, color: color, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      equipo.codigo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      equipo.estado ? 'Operativo' : 'Falla',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (tieneObservacion)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Tooltip(
                    message: equipo.observacion ?? '',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sticky_note_2_rounded, size: 14, color: AppColors.primaryDark),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}