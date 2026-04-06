// ═══════════════════════════════════════════════════════════════════
// FILE:    lib/core/services/user_preferences.dart
// PURPOSE: Speichert und lädt Benutzer-Einstellungen (Name, Atmosphäre,
//          Onboarding-Status) via SharedPreferences.
//          Synchrone Getter nach einmaliger Initialisierung.
// ═══════════════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/atmosphere_model.dart';

class UserPreferences {
  // ─── Singleton ───────────────────────────────────────────────
  UserPreferences._();
  static final UserPreferences _instance = UserPreferences._();
  factory UserPreferences() => _instance;

  // ─── SharedPreferences Instanz ───────────────────────────────
  static SharedPreferences? _prefs;

  // ─── Keys ────────────────────────────────────────────────────
  static const String _keyUserName = 'nexiia_user_name';
  static const String _keyAtmosphereId = 'nexiia_atmosphere_id';
  static const String _keyOnboardingComplete = 'nexiia_onboarding_complete';

  // ─── Initialisierung ────────────────────────────────────────
  /// Muss einmal beim App-Start aufgerufen werden (z.B. in main.dart).
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Stellt sicher, dass _prefs initialisiert ist.
  static SharedPreferences get _safePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'UserPreferences.init() wurde nicht aufgerufen. '
        'Bitte in main.dart vor runApp() aufrufen.',
      );
    }
    return prefs;
  }

  // ─── Benutzername ────────────────────────────────────────────

  /// Speichert den Benutzernamen.
  static Future<bool> setUserName(String name) {
    return _safePrefs.setString(_keyUserName, name.trim());
  }

  /// Gibt den gespeicherten Benutzernamen zurück.
  static String getUserName() {
    return _safePrefs.getString(_keyUserName) ?? '';
  }

  /// Prüft ob ein Benutzername gesetzt ist.
  static bool hasUserName() {
    final name = getUserName();
    return name.isNotEmpty;
  }

  // ─── Atmosphäre ──────────────────────────────────────────────

  /// Speichert die gewählte Atmosphäre per String-ID.
  static Future<bool> setAtmosphere(String atmosphereId) {
    return _safePrefs.setString(_keyAtmosphereId, atmosphereId);
  }

  /// Gibt die String-ID der gespeicherten Atmosphäre zurück.
  static String getAtmosphereId() {
    return _safePrefs.getString(_keyAtmosphereId) ?? '';
  }

  /// Gibt das vollständige AtmosphereModel zurück.
  static AtmosphereModel getAtmosphere() {
    final id = getAtmosphereId();
    if (id.isEmpty) return AtmosphereModel.defaultAtmosphere;
    return AtmosphereModel.fromId(id);
  }

  /// Prüft ob eine Atmosphäre gewählt wurde.
  static bool hasAtmosphere() {
    return getAtmosphereId().isNotEmpty;
  }

  // ─── Onboarding-Status ──────────────────────────────────────

  /// Markiert das Onboarding als abgeschlossen.
  static Future<bool> setOnboardingComplete() {
    return _safePrefs.setBool(_keyOnboardingComplete, true);
  }

  /// Prüft ob das Onboarding abgeschlossen ist.
  static bool isOnboardingComplete() {
    return _safePrefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // ─── Reset ──────────────────────────────────────────────────

  /// Löscht alle Nexiia-Einstellungen.
  static Future<void> clearAll() async {
    await _safePrefs.remove(_keyUserName);
    await _safePrefs.remove(_keyAtmosphereId);
    await _safePrefs.remove(_keyOnboardingComplete);
  }
}