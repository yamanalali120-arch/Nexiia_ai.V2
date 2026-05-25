import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/nexiia_event.dart';
import 'event_intelligence_service.dart';

class SupabaseCalendarService {
  SupabaseCalendarService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<String?> saveEvent({
    required NexiiaEvent event,
    required String title,
    required String note,
    required String location,
    required DateTime start,
    required DateTime end,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      debugPrint(
        'SupabaseCalendarService: Kein eingeloggter User. Event wurde nicht gespeichert.',
      );
      return null;
    }

    final cleanTitle = title.trim().isEmpty ? 'Neuer Termin' : title.trim();
    final cleanNote = note.trim();
    final cleanLocation = location.trim();

    final safeEnd = end.isAfter(start) ? end : start.add(const Duration(hours: 1));
    final durationMinutes = safeEnd.difference(start).inMinutes;

    final intelligence = EventIntelligenceService.analyze(
      title: cleanTitle,
      note: cleanNote,
      location: cleanLocation,
      start: start,
      end: safeEnd,
    );

    final row = {
      'user_id': user.id,
      'client_event_id': event.id,
      'title': cleanTitle,
      'note': cleanNote.isEmpty ? null : cleanNote,
      'location': cleanLocation.isEmpty ? null : cleanLocation,
      'goal': intelligence.goal.name,
      'locked_in_score': intelligence.lockedInScore,
      'locked_in_label': intelligence.label,
      'start_time': start.toUtc().toIso8601String(),
      'end_time': safeEnd.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'is_ai_suggested': event.isAiSuggested,
      'suggestion_source': event.isAiSuggested ? 'nexiia' : null,
      'deleted_at': null,
      'metadata': {
        'source': 'calendar_event_sheet',
        'energy_level': event.energyLevel,
        'event_color': event.color.value,
        'saved_from_app': true,
        'last_sync_action': 'upsert',
        'locked_in_hint': intelligence.hint,
      },
    };

    final upserted = await _client
        .from('calendar_events')
        .upsert(
          row,
          onConflict: 'user_id,client_event_id',
        )
        .select('id')
        .single();

    final calendarEventId = upserted['id'] as String?;

    if (calendarEventId != null) {
      await _saveLockedInScore(
        userId: user.id,
        calendarEventId: calendarEventId,
        score: intelligence.lockedInScore,
        label: intelligence.label,
        goal: intelligence.goal.name,
        factors: {
          'title_present': cleanTitle.trim().isNotEmpty,
          'note_present': cleanNote.isNotEmpty,
          'location_present': cleanLocation.isNotEmpty,
          'duration_minutes': durationMinutes,
          'start_hour': start.hour,
          'end_hour': safeEnd.hour,
          'hint': intelligence.hint,
          'source': 'calendar_save_upsert',
        },
      );

      await _trackAppEvent(
        userId: user.id,
        eventType: 'calendar_event_saved',
        action: 'upsert',
        calendarEventId: calendarEventId,
        clientEventId: event.id,
        metadata: {
          'goal': intelligence.goal.name,
          'locked_in_score': intelligence.lockedInScore,
          'duration_minutes': durationMinutes,
          'title': cleanTitle,
        },
      );
    }

    debugPrint('SupabaseCalendarService: Event upserted: $calendarEventId');
    return calendarEventId;
  }

  static Future<void> softDeleteEventByClientId({
    required String clientEventId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      debugPrint(
        'SupabaseCalendarService: Kein eingeloggter User. Event wurde nicht gelöscht.',
      );
      return;
    }

    await _client
        .from('calendar_events')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', user.id)
        .eq('client_event_id', clientEventId);

    await _trackAppEvent(
      userId: user.id,
      eventType: 'calendar_event_deleted',
      action: 'soft_delete',
      clientEventId: clientEventId,
      metadata: {
        'delete_mode': 'client_event_id',
      },
    );

    debugPrint('SupabaseCalendarService: Event soft deleted: $clientEventId');
  }

  static Future<void> softDeleteEventBySupabaseId({
    required String calendarEventId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      debugPrint(
        'SupabaseCalendarService: Kein eingeloggter User. Event wurde nicht gelöscht.',
      );
      return;
    }

    await _client
        .from('calendar_events')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', calendarEventId)
        .eq('user_id', user.id);

    await _trackAppEvent(
      userId: user.id,
      eventType: 'calendar_event_deleted',
      action: 'soft_delete',
      calendarEventId: calendarEventId,
      metadata: {
        'delete_mode': 'supabase_id',
      },
    );

    debugPrint('SupabaseCalendarService: Event soft deleted: $calendarEventId');
  }

  static Future<List<Map<String, dynamic>>> fetchEventsForCurrentUser() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      debugPrint(
        'SupabaseCalendarService: Kein eingeloggter User. Keine Events geladen.',
      );
      return [];
    }

    final rows = await _client
        .from('calendar_events')
        .select()
        .eq('user_id', user.id)
        .isFilter('deleted_at', null)
        .order('start_time', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> _saveLockedInScore({
    required String userId,
    required String calendarEventId,
    required int score,
    required String label,
    required String goal,
    required Map<String, dynamic> factors,
  }) async {
    await _client.from('locked_in_scores').insert({
      'user_id': userId,
      'calendar_event_id': calendarEventId,
      'score': score,
      'label': label,
      'goal': goal,
      'factors': factors,
    });
  }

  static Future<void> _trackAppEvent({
    required String userId,
    required String eventType,
    required String action,
    String? calendarEventId,
    String? clientEventId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _client.from('app_events').insert({
      'user_id': userId,
      'event_type': eventType,
      'screen_name': 'calendar',
      'action': action,
      'target': 'event_sheet',
      'event_source': 'app',
      'metadata': {
        'calendar_event_id': calendarEventId,
        'client_event_id': clientEventId,
        ...metadata,
      },
    });
  }
}