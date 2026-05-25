import '../models/nexiia_event.dart';

enum EventGoal {
  focus,
  business,
  learning,
  fitness,
  recovery,
  social,
}

class EventIntelligenceResult {
  final EventGoal goal;
  final int lockedInScore;
  final String label;
  final String hint;
  final List<String> suggestions;

  const EventIntelligenceResult({
    required this.goal,
    required this.lockedInScore,
    required this.label,
    required this.hint,
    required this.suggestions,
  });
}

class EventIntelligenceService {
  EventIntelligenceService._();

  static EventIntelligenceResult analyze({
    required String title,
    required String note,
    required String location,
    required DateTime start,
    required DateTime end,
    List<NexiiaEvent> existingEvents = const [],
  }) {
    final goal = inferGoal(title);
    final score = calculateLockedInScore(
      title: title,
      note: note,
      location: location,
      start: start,
      end: end,
      goal: goal,
      existingEvents: existingEvents,
    );

    return EventIntelligenceResult(
      goal: goal,
      lockedInScore: score,
      label: lockedInLabel(score),
      hint: lockedInHint(
        title: title,
        note: note,
        location: location,
        start: start,
        end: end,
        goal: goal,
        score: score,
      ),
      suggestions: suggestionsForGoal(goal),
    );
  }

  static EventGoal inferGoal(String text) {
    final t = text.toLowerCase().trim();

    if (t.contains('training') ||
        t.contains('gym') ||
        t.contains('sport') ||
        t.contains('box') ||
        t.contains('laufen') ||
        t.contains('workout')) {
      return EventGoal.fitness;
    }

    if (t.contains('lernen') ||
        t.contains('study') ||
        t.contains('kurs') ||
        t.contains('prüfung') ||
        t.contains('schule') ||
        t.contains('research')) {
      return EventGoal.learning;
    }

    if (t.contains('call') ||
        t.contains('kunde') ||
        t.contains('client') ||
        t.contains('investor') ||
        t.contains('meeting') ||
        t.contains('sales') ||
        t.contains('business') ||
        t.contains('agentur') ||
        t.contains('pitch')) {
      return EventGoal.business;
    }

    if (t.contains('pause') ||
        t.contains('recovery') ||
        t.contains('reset') ||
        t.contains('ruhe') ||
        t.contains('meditation') ||
        t.contains('spaziergang')) {
      return EventGoal.recovery;
    }

    if (t.contains('familie') ||
        t.contains('freunde') ||
        t.contains('essen') ||
        t.contains('date') ||
        t.contains('social')) {
      return EventGoal.social;
    }

    return EventGoal.focus;
  }

  static int calculateLockedInScore({
    required String title,
    required String note,
    required String location,
    required DateTime start,
    required DateTime end,
    required EventGoal goal,
    List<NexiiaEvent> existingEvents = const [],
  }) {
    int score = 30;

    final cleanTitle = title.trim().toLowerCase();
    final cleanNote = note.trim();
    final cleanLocation = location.trim();
    final duration = end.difference(start).inMinutes;

    if (cleanTitle.isNotEmpty) score += 14;
    if (cleanNote.isNotEmpty) score += 9;
    if (cleanLocation.isNotEmpty) score += 7;

    if (duration >= 45 && duration <= 120) score += 16;
    if (duration > 120 && duration <= 180) score += 9;
    if (duration < 30) score -= 12;
    if (duration > 240) score -= 8;

    switch (goal) {
      case EventGoal.focus:
        if (start.hour >= 8 && start.hour <= 12) score += 16;
        if (duration >= 60 && duration <= 120) score += 10;
        if (start.hour >= 18) score -= 6;
        break;

      case EventGoal.business:
        if (start.hour >= 9 && start.hour <= 17) score += 14;
        if (cleanLocation.isNotEmpty) score += 8;
        if (duration >= 30 && duration <= 90) score += 6;
        break;

      case EventGoal.learning:
        if (duration >= 45 && duration <= 120) score += 14;
        if (cleanNote.isNotEmpty) score += 8;
        if (start.hour >= 8 && start.hour <= 15) score += 7;
        break;

      case EventGoal.fitness:
        if (start.hour >= 6 && start.hour <= 9) score += 8;
        if (start.hour >= 16 && start.hour <= 21) score += 12;
        if (duration >= 45 && duration <= 120) score += 8;
        break;

      case EventGoal.recovery:
        if (duration >= 20 && duration <= 90) score += 14;
        if (start.hour >= 12 && start.hour <= 22) score += 6;
        break;

      case EventGoal.social:
        if (start.hour >= 17) score += 10;
        if (duration >= 60) score += 5;
        break;
    }

    if (cleanTitle.contains('fokus') ||
        cleanTitle.contains('deep') ||
        cleanTitle.contains('lernen') ||
        cleanTitle.contains('training')) {
      score += 8;
    }

    if (start.hour >= 23) score -= 12;

    if (_hasConflict(start, end, existingEvents)) {
      score -= 18;
    }

    if (_hasTooManyEventsSameDay(start, existingEvents)) {
      score -= 8;
    }

    return score.clamp(0, 100);
  }

  static String lockedInLabel(int score) {
    if (score >= 90) return 'Elite geplant';
    if (score >= 78) return 'Sehr sinnvoll';
    if (score >= 62) return 'Solide geplant';
    if (score >= 45) return 'Noch okay';
    return 'Zu unklar';
  }

  static String lockedInHint({
    required String title,
    required String note,
    required String location,
    required DateTime start,
    required DateTime end,
    required EventGoal goal,
    required int score,
  }) {
    final cleanTitle = title.trim();
    final duration = end.difference(start).inMinutes;

    if (cleanTitle.isEmpty) {
      return 'Gib dem Termin einen klaren Titel. Dann kann Nexiia besser einschätzen, ob der Block zu deinem Ziel passt.';
    }

    if (duration < 30) {
      return 'Der Block ist sehr kurz. Für echten Fortschritt sind meistens 45–120 Minuten besser.';
    }

    if (duration > 240) {
      return 'Der Block ist sehr lang. Teile ihn besser in kleinere Abschnitte mit klaren Ergebnissen.';
    }

    if (goal == EventGoal.focus && start.hour > 18) {
      return 'Fokus spät am Tag ist möglich, aber morgens oder vormittags wäre dieser Block meistens stärker.';
    }

    if (goal == EventGoal.business && location.trim().isEmpty) {
      return 'Für Business-Termine ist ein Ort oder Link sinnvoll, damit der Termin vollständig ist.';
    }

    if (goal == EventGoal.learning && note.trim().isEmpty) {
      return 'Für Lernen hilft ein klares Ziel: Was soll nach diesem Block verstanden oder erledigt sein?';
    }

    if (goal == EventGoal.fitness && duration < 45) {
      return 'Für Training wäre ein etwas längerer Block sinnvoll, damit Warm-up und Fokus reinpassen.';
    }

    if (goal == EventGoal.recovery) {
      return 'Guter Reset-Block. Recovery macht deinen nächsten Fokusblock stärker.';
    }

    if (score >= 90) {
      return 'Starker Block. Ziel, Zeitpunkt und Dauer passen sehr gut zusammen.';
    }

    if (score >= 78) {
      return 'Sinnvoll geplant. Mit einem konkreten Ergebnis in der Notiz wird der Block noch stärker.';
    }

    return 'Nexiia bewertet Titel, Ziel, Dauer und Uhrzeit, um deinen Tag smarter zu planen.';
  }

  static List<String> suggestionsForGoal(EventGoal goal) {
    switch (goal) {
      case EventGoal.focus:
        return const [
          'Fokusblock',
          'Deep Work',
          'Konzept fertigstellen',
          'Produkt bauen',
          'Keine Ablenkung',
        ];

      case EventGoal.business:
        return const [
          'Kunden-Call',
          'Sales Follow-up',
          'Investor Pitch',
          'Team Meeting',
          'Angebot erstellen',
        ];

      case EventGoal.learning:
        return const [
          'Lernen',
          'Research',
          'Kurs durcharbeiten',
          'Notizen strukturieren',
          'Skill verbessern',
        ];

      case EventGoal.fitness:
        return const [
          'Training',
          'Gym',
          'Laufen',
          'Mobility',
          'Boxen',
        ];

      case EventGoal.recovery:
        return const [
          'Pause',
          'Recovery',
          'Spaziergang',
          'Meditation',
          'Reset',
        ];

      case EventGoal.social:
        return const [
          'Freunde',
          'Familie',
          'Essen',
          'Date',
          'Social Time',
        ];
    }
  }

  static bool _hasConflict(
    DateTime start,
    DateTime end,
    List<NexiiaEvent> events,
  ) {
    for (final event in events) {
      final overlaps = start.isBefore(event.end) && end.isAfter(event.start);
      if (overlaps) return true;
    }

    return false;
  }

  static bool _hasTooManyEventsSameDay(
    DateTime start,
    List<NexiiaEvent> events,
  ) {
    final sameDayEvents = events.where((event) {
      return event.start.year == start.year &&
          event.start.month == start.month &&
          event.start.day == start.day;
    }).length;

    return sameDayEvents >= 7;
  }
}