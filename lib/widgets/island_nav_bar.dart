import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Un botón dentro de la isla de navegación.
class IslandNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Si es `true`, el botón se resalta con el color primario (se usa
  /// para la acción principal de cada pantalla, ej. "Nuevo").
  final bool destacado;

  const IslandNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destacado = false,
  });
}

/// "Isla" de navegación flotante, fija en la parte inferior de la
/// pantalla y reutilizada en TODAS las vistas de la app (Salones,
/// Detalle de salón, etc.) para mantener una navegación consistente.
///
/// Ergonomía aplicada (Regla del Pulgar): al flotar sobre el contenido
/// en la franja inferior de la pantalla, las acciones principales quedan
/// siempre al alcance del pulgar, sin importar qué tan larga sea la
/// lista o grid que se esté mostrando arriba.
class IslandNavBar extends StatelessWidget {
  final List<IslandNavItem> items;

  const IslandNavBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.islandBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.islandShadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _IslandButton(item: item),
              ),
            )
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
    final Color bg = item.destacado ? AppColors.primaryDark : Colors.transparent;
    final Color fg = item.destacado ? Colors.white : AppColors.textPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: item.onTap,
        child: Container(
          // Área táctil >= 44px de alto, cumpliendo ergonomía móvil.
          constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: fg, size: 22),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
