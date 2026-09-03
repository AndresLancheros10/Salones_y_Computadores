import 'package:flutter/material.dart';
import '../models/equipo.dart';

/// Tarjeta que representa un equipo dentro del GridView.
/// Semáforo visual: verde = operativo, rojo = falla.
/// Área táctil >= 44px de alto para cumplir con ergonomía móvil.
class EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;

  const EquipoCard({super.key, required this.equipo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = equipo.estado ? Colors.green : Colors.red;
    final IconData icono =
        equipo.estado ? Icons.check_circle : Icons.error;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Icon(icono, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  equipo.codigo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  equipo.estado ? 'Operativo' : 'Falla',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
