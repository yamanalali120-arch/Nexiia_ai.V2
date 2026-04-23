import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingService {
  // Singleton Pattern - nur EINE Instanz in der ganzen App
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  String? _currentSessionId;
  String? _currentConversationId;

  // ============================================
  // USER ID
  // ============================================
  String? get userId => _supabase.auth.currentUser?.id;

  // ============================================
  // SESSION (bei App-Start aufrufen)
  // ============================================
  Future<void> startSession({String? os, String? deviceType}) async {
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('user_sessions')
          .insert({
            'user_id': userId,
            'device_type': deviceType ?? 'mobile',
            'os': os ?? 'unknown',
            'app_version': '1.0.0',
            'is_active': true,
          })
          .select()
          .single();

      _currentSessionId = response['id'];
      print('✅ Session gestartet: $_currentSessionId');
    } catch (e) {
      print('❌ Session Error: $e');
    }
  }

  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    try {
      await _supabase.from('user_sessions').update({
        'ended_at': DateTime.now().toIso8601String(),
        'is_active': false,
      }).eq('id', _currentSessionId!);
      print('✅ Session beendet');
    } catch (e) {
      print('❌ End Session Error: $e');
    }
  }

  // ============================================
  // CONVERSATION
  // ============================================
  Future<String?> createConversation({String title = 'Neuer Chat'}) async {
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('conversations')
          .insert({
            'user_id': userId,
            'session_id': _currentSessionId,
            'title': title,
            'model_used': 'llama-3.3-70b-versatile',
            'status': 'active',
          })
          .select()
          .single();

      _currentConversationId = response['id'];
      print('✅ Conversation erstellt: $_currentConversationId');
      return _currentConversationId;
    } catch (e) {
      print('❌ Conversation Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', userId!)
          .eq('status', 'active')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Load Conversations Error: $e');
      return [];
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _supabase
          .from('conversations')
          .update({'status': 'deleted'}).eq('id', conversationId);
    } catch (e) {
      print('❌ Delete Conversation Error: $e');
    }
  }

  Future<void> updateConversationTitle(String convId, String title) async {
    try {
      await _supabase
          .from('conversations')
          .update({'title': title}).eq('id', convId);
    } catch (e) {
      print('❌ Update Title Error: $e');
    }
  }

  // ============================================
  // MESSAGES SPEICHERN
  // ============================================
  Future<String?> saveMessage({
    required String conversationId,
    required String role,
    required String content,
    String? model,
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
    int? responseTimeMs,
    bool isError = false,
    String? errorMessage,
  }) async {
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'user_id': userId,
            'role': role,
            'content': content,
            'model': model,
            'prompt_tokens': promptTokens ?? 0,
            'completion_tokens': completionTokens ?? 0,
            'total_tokens': totalTokens ?? 0,
            'response_time_ms': responseTimeMs,
            'is_error': isError,
            'error_message': errorMessage,
          })
          .select()
          .single();

      // Counter updaten
      try {
        await _supabase.rpc('increment_message_count', params: {
          'conv_id': conversationId,
          'token_count': totalTokens ?? 0,
        });
      } catch (e) {
        print('⚠️ Counter Update fehlgeschlagen: $e');
      }

      // Profil Stats updaten
      await _updateProfileStats(totalTokens ?? 0);

      return response['id'];
    } catch (e) {
      print('❌ Save Message Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Load Messages Error: $e');
      return [];
    }
  }

  // ============================================
  // FEEDBACK
  // ============================================
  Future<void> saveFeedback(String messageId, bool thumbsUp) async {
    try {
      await _supabase
          .from('messages')
          .update({'thumbs_up': thumbsUp}).eq('id', messageId);
    } catch (e) {
      print('❌ Feedback Error: $e');
    }
  }

  // ============================================
  // EVENT TRACKING
  // ============================================
  Future<void> trackEvent(
    String eventType,
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (userId == null) return;

    try {
      await _supabase.from('user_events').insert({
        'user_id': userId,
        'session_id': _currentSessionId,
        'event_type': eventType,
        'event_name': eventName,
        'properties': properties ?? {},
      });
    } catch (e) {
      print('❌ Event Error: $e');
    }
  }

  // ============================================
  // API REQUEST LOGGEN
  // ============================================
  Future<void> logApiRequest({
    required String endpoint,
    required int statusCode,
    required int durationMs,
    int? tokensUsed,
    double? costUsd,
  }) async {
    if (userId == null) return;

    try {
      await _supabase.from('api_requests').insert({
        'user_id': userId,
        'endpoint': endpoint,
        'method': 'POST',
        'status_code': statusCode,
        'duration_ms': durationMs,
        'tokens_used': tokensUsed ?? 0,
        'cost_usd': costUsd ?? 0,
      });
    } catch (e) {
      print('❌ API Log Error: $e');
    }
  }

  // ============================================
  // PROFIL STATS
  // ============================================
  Future<void> _updateProfileStats(int tokens) async {
    if (userId == null) return;

    try {
      final profile = await _supabase
          .from('profiles')
          .select('total_messages_sent, total_tokens_used')
          .eq('id', userId!)
          .single();

      await _supabase.from('profiles').update({
        'total_messages_sent': (profile['total_messages_sent'] ?? 0) + 1,
        'total_tokens_used': (profile['total_tokens_used'] ?? 0) + tokens,
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('id', userId!);
    } catch (e) {
      print('❌ Profile Stats Error: $e');
    }
  }

  Future<void> updateLastActive() async {
    if (userId == null) return;

    try {
      await _supabase.from('profiles').update({
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('id', userId!);
    } catch (e) {
      print('❌ Last Active Error: $e');
    }
  }

  // Getter
  String? get currentSessionId => _currentSessionId;
  String? get currentConversationId => _currentConversationId;
  set currentConversationId(String? id) => _currentConversationId = id;
}
