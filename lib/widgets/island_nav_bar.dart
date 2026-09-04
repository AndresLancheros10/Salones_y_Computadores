import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Un botón dentro de la isla de navegación.
class IslandNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Si es `true`, el ícono y la etiqueta se pintan en el color primario
  /// para indicar "estamos aquí" (sin rellenar el fondo).
  final bool activo;

  /// Número a mostrar en una insignia roja sobre el ícono (ej. cantidad
  /// de equipos que requieren atención técnica). `null` = sin insignia.
  final int? badge;

  const IslandNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.activo = false,
    this.badge,
  });
}

/// "Isla" de navegación flotante, fija en la parte inferior de la
/// pantalla y reutilizada en TODAS las vistas de la app para mantener
/// una navegación consistente.
///
/// Ergonomía aplicada (Regla del Pulgar): al flotar sobre el contenido
/// en la franja inferior de la pantalla, las acciones principales quedan
/// siempre al alcance del pulgar.
class IslandNavBar extends StatelessWidget {
  final List<IslandNavItem> items;

  const IslandNavBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.islandBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.islandShadow, blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _IslandButton(item: item),
                ))
            .toList(),
      ),
    );
  }
}

class _IslandButton extends StatelessWidget {
  final IslandNavItem item;
  const _IslandButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color fg = item.activo ? AppColors.primaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: item.onTap,
        child: Container(
          // Área táctil >= 44px, cumpliendo ergonomía móvil.
          constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon, color: fg, size: 24),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(color: AppColors.falla, borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          item.badge! > 9 ? '9+' : '${item.badge}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(color: fg, fontSize: 11, fontWeight: item.activo ? FontWeight.w800 : FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
