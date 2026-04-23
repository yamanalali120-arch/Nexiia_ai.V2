//
// FILE:    lib/main.dart
// PURPOSE: App-Einstiegspunkt. Initialisiert alle Services und
//          startet die NexiiaApp.
//
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/services/user_preferences.dart';
import 'core/services/tracking_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env Datei laden (für API Keys)
  await dotenv.load(fileName: ".env");

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

  // ✅ NEU: Session-Tracking starten
  final tracking = TrackingService();
  if (Supabase.instance.client.auth.currentUser != null) {
    await tracking.startSession(
      os: _getOS(),
      deviceType: 'mobile',
    );
    await tracking.updateLastActive();
    print('✅ Tracking Session gestartet');
  }

  // ProviderScope für Riverpod
  runApp(
    const ProviderScope(
      child: NexiiaApp(),
    ), // ProviderScope
  );
}

// Helper: OS erkennen
String _getOS() {
  try {
    if (identical(0, 0.0)) return 'web';
    // Für bessere Erkennung: import 'dart:io';
    // return Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'unknown';
    return 'mobile';
  } catch (e) {
    return 'unknown';
  }
}
 