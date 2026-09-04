import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/salones_screen.dart';
import 'theme/app_theme.dart';

/// ⚠️ IMPORTANTE: reemplaza estos valores por los de TU proyecto Supabase.
/// Los encuentras en: Project Settings -> API, en tu panel de Supabase.
const String kSupabaseUrl = 'https://cacczcomjpferoeyhlsn.supabase.co';
const String kSupabaseAnonKey = 'sb_publishable_bmE6vSd41WDEmBljFpu7TQ_mkPuv2aU';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(const MonitorSalonApp());
}

class MonitorSalonApp extends StatelessWidget {
  const MonitorSalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Salones',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SalonesScreen(),
    );
  }
}
