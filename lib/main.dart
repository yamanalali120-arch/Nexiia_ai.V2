// ═══════════════════════════════════════════════════════════════════
// FILE:    lib/main.dart
// PURPOSE: App-Einstiegspunkt. Initialisiert alle Services und
//          startet die NexiiaApp.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/services/user_preferences.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppTheme.setSystemUI();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://rrmbdrknivspquhioluq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJybWJkcmtuaXZzcHF1aGlvbHVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MjAzMTksImV4cCI6MjA5MDE5NjMxOX0.oPobUnNZjAOR589MSNEcqTeWbmVyCLMxL1LH2P8XrMk',
  );

  await UserPreferences.init();

  runApp(const NexiiaApp());
}
// Teste den Zugriff auf "Project X"
void testSupabase() async {
  try {
    final response = await Supabase.instance.client.from('Project X').select('*');
    print('Daten erfolgreich geladen: $response');
  } catch (e) {
    print('Fehler beim Laden: $e');
  }
}