import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/tracking_service.dart';
import '../models/chat_message.dart';

class NexiiaAI {
  final List<ChatMessage> _chatHistory = [];
  final TrackingService _tracking = TrackingService();

  static const String _systemPrompt = '''
# NEXIIA – System Prompt v2.1 | DioYama Enterprise
## WER DU BIST
Du bist NEXIIA – ein empathischer, intelligenter persönlicher Companion.
Du wurdest vom Team rund um Yaman bei DioYama Enterprise entwickelt.

Wenn jemand fragt wer dich erstellt hat:
"Ich wurde von Yaman und dem Team bei DioYama Enterprise entwickelt."
Du bist KEIN Produkt von OpenAI, Google, Meta oder anderen.
Sage NIEMALS "Ich bin ChatGPT", "Ich bin LLaMA" oder "Ich bin ein Sprachmodell".
Sage: "Ich bin Nexiia, dein persönlicher Companion von DioYama Enterprise."

## DEINE PERSÖNLICHKEIT
- Warmherzig aber DIREKT
- Emotional intelligent
- NICHT toxisch positiv
- Wie ein weiser bester Freund
- Trockener, intelligenter Humor
- PROAKTIV

## SPRACHE
- DEUTSCH (du-Form)
- Natürlich wie ein Mensch
- Emojis SPARSAM (max 1-2)
- Max 200 Wörter pro Antwort

VERBOTEN:
- "Als KI..." / "Ich bin ein Sprachmodell..."
- "Ich habe keine Gefühle..."
- "Das ist eine tolle Frage!"

## RECHTLICHE ABSICHERUNG
### Medizin
Du bist KEIN Arzt. Keine Diagnosen. Keine Medikamente.

### Psychologie
Du bist KEIN Therapeut. Keine Diagnosen.

### Krise & Suizid
Bei Suizidgedanken IMMER Notfallnummern nennen:
Telefonseelsorge: 0800 111 0 111 (kostenlos, 24/7)
Kinder & Jugend: 116 111
Notarzt: 112

### Recht & Finanzen
Keine rechtsverbindlichen Auskünfte.

## WICHTIGE VERHALTENSREGEL BEI APP-BEFEHLEN

Wenn der User etwas will das eine Aktion erfordert (Termin, Erinnerung, Tagesplan etc.):
1. Frage ZUERST nach ALLEN fehlenden Details
2. Bestätige die Details mit dem User
3. ERST DANN führe die Aktion aus

Beispiel Termin:
User: "Trag mir einen Termin ein"
Du: "Klar! Dafür brauche ich ein paar Infos:
- Was ist der Anlass?
- Welches Datum?
- Welche Uhrzeit (Start und Ende)?
- Soll ich dich vorher erinnern?"

Beispiel Tagesplan:
User: "Erstelle einen Tagesplan"
Du: "Gerne! Damit ich dir einen richtig guten Plan bauen kann:
- Für welchen Tag?
- Hast du schon feste Termine?
- Was sind deine Prioritäten heute?
- Wann stehst du auf / gehst du schlafen?"

NIEMALS eine Aktion ausführen ohne alle nötigen Infos zu haben!

## APP-BEFEHLE (Intent-System)

Wenn du ALLE Infos hast und die Aktion ausführst:
1. Schreibe ZUERST deine natürliche Bestätigung
2. Setze den Intent-Block ans ENDE deiner Nachricht
3. Der Intent-Block wird automatisch entfernt

Format: [INTENT]{"intent":"...", ...}[/INTENT]

Verfügbare Intents:
- create_appointment: title, date (YYYY-MM-DD), start_time (HH:MM), end_time (HH:MM), category
- move_appointment: original_title, new_date, new_start_time, new_end_time
- delete_appointment: title, date
- create_reminder: title, datetime (YYYY-MM-DD HH:MM)
- open_solve: problem, ursache, auswirkung, loesungen[], massnahme, erkenntnis
- create_dayplan: tasks[{title, time, duration_min, category}]
- create_journal: mood (gut/okay/schlecht), text
- start_focus: duration_min, title
- navigate: target (home/chat/solve/planner/focus)

WICHTIG:
- NIEMALS Intent ohne natürliche Antwort davor
- Fehlende Infos IMMER NACHFRAGEN
- Aktion in deiner Antwort BESTÄTIGEN
''';

  NexiiaAI() {
    _chatHistory.add(ChatMessage(
      role: 'system',
      content: _systemPrompt,
    ));
  }

  // ═══════════════════════════════════════════════════════
  // INTENT EXTRACTION — STRING-BASIERT (kein Regex!)
  // ═══════════════════════════════════════════════════════

  static const String _openTag = '[INTENT]';
  static const String _closeTag = '[/INTENT]';

  Map<String, dynamic>? extractIntent(String message) {
    final int startIdx = message.indexOf(_openTag);
    if (startIdx == -1) return null;

    final int jsonStart = startIdx + _openTag.length;
    int endIdx = message.indexOf(_closeTag, jsonStart);

    // Falls kein Close-Tag: nimm den Rest der Nachricht
    final String jsonStr;
    if (endIdx == -1) {
      jsonStr = message.substring(jsonStart).trim();
    } else {
      jsonStr = message.substring(jsonStart, endIdx).trim();
    }

    if (jsonStr.isEmpty) return null;

    try {
      final parsed = jsonDecode(jsonStr);
      if (parsed is Map<String, dynamic> && parsed.containsKey('intent')) {
        return parsed;
      }
    } catch (e) {
      debugPrint('Intent parse error: $e');
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════
  // MESSAGE CLEANING — STRING-BASIERT (kein Regex!)
  // ═══════════════════════════════════════════════════════

  String cleanMessage(String message) {
    String cleaned = message;

    // Entferne alle [INTENT]...[/INTENT] Blöcke (auch mehrere)
    while (true) {
      final int startIdx = cleaned.indexOf(_openTag);
      if (startIdx == -1) break;

      final int endIdx = cleaned.indexOf(_closeTag, startIdx);
      if (endIdx != -1) {
        // Entferne von [INTENT] bis einschließlich [/INTENT]
        cleaned = cleaned.substring(0, startIdx) +
            cleaned.substring(endIdx + _closeTag.length);
      } else {
        // Kein Close-Tag: entferne alles ab [INTENT]
        cleaned = cleaned.substring(0, startIdx);
      }
    }

    // Entferne alleinstehende Tags die übrig sein könnten
    cleaned = cleaned.replaceAll(_openTag, '');
    cleaned = cleaned.replaceAll(_closeTag, '');

    // Entferne rohes JSON mit "intent" key (Fallback)
    cleaned = _removeRawIntentJson(cleaned);

    // Cleanup
    cleaned = cleaned.trim();
    while (cleaned.contains('\n\n\n')) {
      cleaned = cleaned.replaceAll('\n\n\n', '\n\n');
    }

    if (cleaned.isEmpty) {
      cleaned = 'Erledigt ✓';
    }

    return cleaned;
  }

  String _removeRawIntentJson(String text) {
    // Suche nach {"intent": im Text und entferne den ganzen JSON-Block
    int searchFrom = 0;
    String result = text;

    while (true) {
      final int idx = result.indexOf('"intent"', searchFrom);
      if (idx == -1) break;

      // Finde die öffnende {
      int braceStart = idx - 1;
      while (braceStart >= 0 && result[braceStart] != '{') {
        braceStart--;
      }
      if (braceStart < 0) {
        searchFrom = idx + 1;
        continue;
      }

      // Finde die schließende }
      int braceCount = 0;
      int braceEnd = braceStart;
      for (int i = braceStart; i < result.length; i++) {
        if (result[i] == '{') braceCount++;
        if (result[i] == '}') braceCount--;
        if (braceCount == 0) {
          braceEnd = i;
          break;
        }
      }

      if (braceCount == 0) {
        result = result.substring(0, braceStart) +
            result.substring(braceEnd + 1);
      } else {
        searchFrom = idx + 1;
      }
    }

    return result;
  }

  /// LETZTE VERTEIDIGUNG: Nochmal alles säubern bevor es in die UI geht
  static String sanitizeForUI(String text) {
    String safe = text;

    // String-basierte Entfernung
    while (safe.contains(_openTag)) {
      final int start = safe.indexOf(_openTag);
      final int end = safe.indexOf(_closeTag, start);
      if (end != -1) {
        safe = safe.substring(0, start) + safe.substring(end + _closeTag.length);
      } else {
        safe = safe.substring(0, start);
      }
    }

    safe = safe.replaceAll(_openTag, '');
    safe = safe.replaceAll(_closeTag, '');

    safe = safe.trim();
    while (safe.contains('\n\n\n')) {
      safe = safe.replaceAll('\n\n\n', '\n\n');
    }

    if (safe.isEmpty) safe = 'Erledigt ✓';
    return safe;
  }

  // ═══════════════════════════════════════════════════════
  // SEND MESSAGE
  // ═══════════════════════════════════════════════════════

  Future<String> sendMessage(String userMessage) async {
    _chatHistory.add(ChatMessage(
      role: 'user',
      content: userMessage,
    ));

    String? conversationId = _tracking.currentConversationId;
    if (conversationId == null) {
      conversationId = await _tracking.createConversation(
        title: userMessage.length > 50
            ? '${userMessage.substring(0, 50)}...'
            : userMessage,
      );
    }

    if (conversationId != null) {
      await _tracking.saveMessage(
        conversationId: conversationId,
        role: 'user',
        content: userMessage,
      );
    }

    await _tracking.trackEvent('chat', 'message_sent', properties: {
      'message_length': userMessage.length,
      'conversation_id': conversationId,
    });

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return 'Fehler: API Key nicht gefunden. Prüfe deine .env Datei.';
      }

      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        Uri.parse('${ApiConstants.groqBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': ApiConstants.defaultModel,
          'messages': _chatHistory.map((m) => m.toJson()).toList(),
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['choices'][0]['message']['content'] as String;

        final usage = data['usage'];
        final promptTokens = usage?['prompt_tokens'] ?? 0;
        final completionTokens = usage?['completion_tokens'] ?? 0;
        final totalTokens = usage?['total_tokens'] ?? 0;

        _chatHistory.add(ChatMessage(
          role: 'assistant',
          content: aiMessage,
        ));

        if (conversationId != null) {
          await _tracking.saveMessage(
            conversationId: conversationId,
            role: 'assistant',
            content: aiMessage,
            model: ApiConstants.defaultModel,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            totalTokens: totalTokens,
            responseTimeMs: responseTimeMs,
          );
        }

        await _tracking.logApiRequest(
          endpoint: '${ApiConstants.groqBaseUrl}/chat/completions',
          statusCode: response.statusCode,
          durationMs: responseTimeMs,
          tokensUsed: totalTokens,
          costUsd: (totalTokens / 1000) * 0.00059,
        );

        if (_chatHistory.where((m) => m.role == 'user').length == 1) {
          await _tracking.updateConversationTitle(
            conversationId!,
            userMessage.length > 80
                ? '${userMessage.substring(0, 80)}...'
                : userMessage,
          );
        }

        return aiMessage;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg =
            'Fehler: ${error['error']?['message'] ?? 'Status ${response.statusCode}'}';

        if (conversationId != null) {
          await _tracking.saveMessage(
            conversationId: conversationId,
            role: 'assistant',
            content: errorMsg,
            isError: true,
            errorMessage: errorMsg,
            responseTimeMs: stopwatch.elapsedMilliseconds,
          );
        }

        await _tracking.trackEvent('error', 'api_error', properties: {
          'status_code': response.statusCode,
          'error': errorMsg,
        });

        await _tracking.logApiRequest(
          endpoint: '${ApiConstants.groqBaseUrl}/chat/completions',
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
        );

        return errorMsg;
      }
    } catch (e) {
      final errorMsg = 'Verbindungsfehler: $e';

      if (conversationId != null) {
        await _tracking.saveMessage(
          conversationId: conversationId,
          role: 'assistant',
          content: errorMsg,
          isError: true,
          errorMessage: errorMsg,
        );
      }

      await _tracking.trackEvent('error', 'connection_error', properties: {
        'error': e.toString(),
      });

      return errorMsg;
    }
  }

  void startNewConversation() {
    _tracking.currentConversationId = null;
    clearHistory();
  }

  void clearHistory() {
    _chatHistory.clear();
    _chatHistory.add(ChatMessage(
      role: 'system',
      content: _systemPrompt,
    ));
  }

  List<ChatMessage> get history =>
      _chatHistory.where((m) => !m.isSystem).toList();

  TrackingService get tracking => _tracking;
}