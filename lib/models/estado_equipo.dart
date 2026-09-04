import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Los 4 estados posibles de un computador.
enum EstadoEquipo {
  disponible,
  enUso,
  danado,
  mantenimiento,
}

extension EstadoEquipoInfo on EstadoEquipo {
  /// Valor que se guarda en la columna `estado_texto` de Supabase.
  String get valorDb {
    switch (this) {
      case EstadoEquipo.disponible:
        return 'disponible';
      case EstadoEquipo.enUso:
        return 'en_uso';
      case EstadoEquipo.danado:
        return 'danado';
      case EstadoEquipo.mantenimiento:
        return 'mantenimiento';
    }
  }

  /// Texto legible para mostrar en la interfaz.
  String get etiqueta {
    switch (this) {
      case EstadoEquipo.disponible:
        return 'Disponible';
      case EstadoEquipo.enUso:
        return 'En uso';
      case EstadoEquipo.danado:
        return 'Dañado';
      case EstadoEquipo.mantenimiento:
        return 'Mantenimiento';
    }
  }

  /// Color principal para textos, iconos y estados.
  Color get color {
    switch (this) {
      case EstadoEquipo.disponible:
        return AppColors.operativo;
      case EstadoEquipo.enUso:
        return AppColors.enUso;
      case EstadoEquipo.danado:
        return AppColors.falla;
      case EstadoEquipo.mantenimiento:
        return AppColors.mantenimiento;
    }
  }

  /// Color de fondo para tarjetas y chips.
  Color get colorFondo {
    switch (this) {
      case EstadoEquipo.disponible:
        return AppColors.operativoBg;
      case EstadoEquipo.enUso:
        return AppColors.enUsoBg;
      case EstadoEquipo.danado:
        return AppColors.fallaBg;
      case EstadoEquipo.mantenimiento:
        return AppColors.mantenimientoBg;
    }
  }

  /// Icono correspondiente al estado.
  IconData get icono {
    switch (this) {
      case EstadoEquipo.disponible:
        return Icons.check_circle_rounded;
      case EstadoEquipo.enUso:
        return Icons.play_circle_rounded;
      case EstadoEquipo.danado:
        return Icons.error_rounded;
      case EstadoEquipo.mantenimiento:
        return Icons.build_circle_rounded;
    }
  }

  /// Indica si el equipo necesita atención técnica.
  bool get requiereAtencion {
    return this == EstadoEquipo.danado ||
        this == EstadoEquipo.mantenimiento;
  }

  /// Convierte el valor almacenado en Supabase al enum.
  static EstadoEquipo desdeDb(String? valor) {
    switch (valor) {
      case 'en_uso':
        return EstadoEquipo.enUso;
      case 'danado':
        return EstadoEquipo.danado;
      case 'mantenimiento':
        return EstadoEquipo.mantenimiento;
      case 'disponible':
      default:
        return EstadoEquipo.disponible;
    }
  }
}