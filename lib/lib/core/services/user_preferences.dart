// ═══════════════════════════════════════════════════════════════════
// FILE:    lib/core/services/user_preferences.dart
// PURPOSE: Speichert und lädt Benutzer-Einstellungen (Name, Atmosphäre,
//          Onboarding-Status, Feature-Intros, Entity-Position)
//          via SharedPreferences.
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

  // Feature-Intro Flags
  static const String _keySeenHomeIntro = 'nexiia_seen_home_intro';
  static const String _keySeenChatIntro = 'nexiia_seen_chat_intro';
  static const String _keySeenSolveIntro = 'nexiia_seen_solve_intro';
  static const String _keySeenPlannerIntro = 'nexiia_seen_planner_intro';
  static const String _keySeenFocusIntro = 'nexiia_seen_focus_intro';

  // Entity Position
  static const String _keyEntityX = 'nexiia_entity_pos_x';
  static const String _keyEntityY = 'nexiia_entity_pos_y';

  // ─── Initialisierung ────────────────────────────────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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
  static Future<bool> setUserName(String name) {
    return _safePrefs.setString(_keyUserName, name.trim());
  }

  static String getUserName() {
    return _safePrefs.getString(_keyUserName) ?? '';
  }

  static bool hasUserName() {
    final name = getUserName();
    return name.isNotEmpty;
  }

  // ─── Atmosphäre ──────────────────────────────────────────────
  static Future<bool> setAtmosphere(String atmosphereId) {
    return _safePrefs.setString(_keyAtmosphereId, atmosphereId);
  }

  static String getAtmosphereId() {
    return _safePrefs.getString(_keyAtmosphereId) ?? '';
  }

  static AtmosphereModel getAtmosphere() {
    final id = getAtmosphereId();
    if (id.isEmpty) return AtmosphereModel.defaultAtmosphere;
    return AtmosphereModel.fromId(id);
  }

  static bool hasAtmosphere() {
    return getAtmosphereId().isNotEmpty;
  }

  // ─── Onboarding-Status ──────────────────────────────────────
  static Future<bool> setOnboardingComplete() {
    return _safePrefs.setBool(_keyOnboardingComplete, true);
  }

  static bool isOnboardingComplete() {
    return _safePrefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // ─── Feature-Intro Flags ────────────────────────────────────
  static Future<bool> setSeenIntro(String featureKey) {
    return _safePrefs.setBool(featureKey, true);
  }

  static bool hasSeenIntro(String featureKey) {
    return _safePrefs.getBool(featureKey) ?? false;
  }

  static bool get hasSeenHomeIntro => hasSeenIntro(_keySeenHomeIntro);
  static bool get hasSeenChatIntro => hasSeenIntro(_keySeenChatIntro);
  static bool get hasSeenSolveIntro => hasSeenIntro(_keySeenSolveIntro);
  static bool get hasSeenPlannerIntro => hasSeenIntro(_keySeenPlannerIntro);
  static bool get hasSeenFocusIntro => hasSeenIntro(_keySeenFocusIntro);

  static Future<bool> markHomeIntroSeen() => setSeenIntro(_keySeenHomeIntro);
  static Future<bool> markChatIntroSeen() => setSeenIntro(_keySeenChatIntro);
  static Future<bool> markSolveIntroSeen() => setSeenIntro(_keySeenSolveIntro);
  static Future<bool> markPlannerIntroSeen() => setSeenIntro(_keySeenPlannerIntro);
  static Future<bool> markFocusIntroSeen() => setSeenIntro(_keySeenFocusIntro);

  // ─── Entity Position (Draggable) ────────────────────────────
  static Future<void> setEntityPosition(double x, double y) async {
    await _safePrefs.setDouble(_keyEntityX, x);
    await _safePrefs.setDouble(_keyEntityY, y);
  }

  static double? getEntityX() {
    return _safePrefs.containsKey(_keyEntityX)
        ? _safePrefs.getDouble(_keyEntityX)
        : null;
  }

  static double? getEntityY() {
    return _safePrefs.containsKey(_keyEntityY)
        ? _safePrefs.getDouble(_keyEntityY)
        : null;
  }

  static bool hasEntityPosition() {
    return _safePrefs.containsKey(_keyEntityX) &&
        _safePrefs.containsKey(_keyEntityY);
  }

  // ─── Reset ──────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _safePrefs.remove(_keyUserName);
    await _safePrefs.remove(_keyAtmosphereId);
    await _safePrefs.remove(_keyOnboardingComplete);
    await _safePrefs.remove(_keySeenHomeIntro);
    await _safePrefs.remove(_keySeenChatIntro);
    await _safePrefs.remove(_keySeenSolveIntro);
    await _safePrefs.remove(_keySeenPlannerIntro);
    await _safePrefs.remove(_keySeenFocusIntro);
    await _safePrefs.remove(_keyEntityX);
    await _safePrefs.remove(_keyEntityY);
  }
}