# 📡 Monitor Salón 317 — Flutter + Supabase

App móvil que permite a instructores y aprendices identificar en menos de
3 segundos si un equipo del Salón 317 está **operativo** o **con falla**,
con sincronización en tiempo real (Supabase Realtime / CDC).

> Proyecto desarrollado para la guía de aprendizaje **GFPI-F-135** —
> Programa Análisis y Desarrollo de Software (SENA), código 228118.

## Vista previa

| Listado en tiempo real | Formulario táctil |
| --- | --- |
| _agrega aquí `docs/capturas/01-listado.png`_ | _agrega aquí `docs/capturas/02-detalle.png`_ |

🎥 Video de demostración: _pega aquí el enlace a YouTube/Drive_

## Tecnologías

- **Flutter (Dart)** — frontend móvil multiplataforma
- **Supabase** — Backend as a Service (PostgreSQL + Realtime + Auth)
- Patrón **StreamBuilder** para UI reactiva ante cambios en la base de datos

## Estructura del repositorio

```
Salones_y_Computadores/
├── lib/
│   ├── main.dart
│   ├── models/equipo.dart
│   ├── services/supabase_service.dart
│   ├── screens/home_screen.dart
│   ├── screens/detalle_equipo_screen.dart
│   └── widgets/equipo_card.dart
├── sql/schema.sql
├── docs/
│   └── capturas/
├── pubspec.yaml
└── README.md
```

## Cómo ejecutarlo localmente

```bash
git clone https://github.com/TU-USUARIO/Salones_y_Computadores.git
cd Salones_y_Computadores
flutter create .          # genera android/, ios/, web/ (no se versionan)
flutter pub get
```

1. Crea un proyecto en [supabase.com](https://supabase.com) y ejecuta
   `sql/schema.sql` en su SQL Editor.
2. En `lib/main.dart`, reemplaza `kSupabaseUrl` y `kSupabaseAnonKey` por
   los de tu proyecto (Project Settings → API).
3. Ejecuta:
   ```bash
   flutter run
   ```

## Ergonomía aplicada

- **Regla del Pulgar**: acción principal ("Guardar") anclada en la parte
  inferior de la pantalla.
- **Semáforo visual**: verde = operativo, rojo = falla.
- **Formularios táctiles**: controles con alto mínimo de 44px.

## Autor

**[Tu nombre]** — Aprendiz ADSO, ficha [tu ficha] — SENA
