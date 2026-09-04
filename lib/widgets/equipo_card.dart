import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../theme/app_theme.dart';
import '../models/estado_equipo.dart';

/// Tarjeta que representa un equipo dentro del GridView.
///
/// El color cambia según el estado:
/// - Disponible
/// - En uso
/// - Dañado
/// - Mantenimiento
///
/// Si el equipo tiene una observación, aparece un icono de nota.
class EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const EquipoCard({
    super.key,
    required this.equipo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = equipo.estado;

    final color = estado.color;
    final colorFondo = estado.colorFondo;

    final observacion =
        (equipo.observacion ?? '').trim();

    final tieneObservacion = observacion.isNotEmpty;

    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 44,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                color.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      Icons.computer_rounded,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${equipo.numero}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estado.etiqueta,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              if (tieneObservacion)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Tooltip(
                    message: observacion,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration:
                          const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sticky_note_2_rounded,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
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