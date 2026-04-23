import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

// ============================================
// PROVIDERS
// ============================================

// Der AI Service
final nexiiaAIProvider = Provider<NexiiaAI>((ref) {
  return NexiiaAI();
});

// Loading State (true wenn KI antwortet)
final isAILoadingProvider = StateProvider<bool>((ref) => false);

// Alle Chat Nachrichten
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

// ============================================
// FUNKTIONEN
// ============================================

Future<void> sendMessageToAI({
  required WidgetRef ref,
  required String message,
}) async {
  final ai = ref.read(nexiiaAIProvider);

  // User Nachricht sofort anzeigen
  ref.read(chatMessagesProvider.notifier).state = [
    ...ref.read(chatMessagesProvider),
    ChatMessage(role: 'user', content: message),
  ];

  // Loading an
  ref.read(isAILoadingProvider.notifier).state = true;

  // AI Antwort holen
  final response = await ai.sendMessage(message);

  // AI Antwort anzeigen
  ref.read(chatMessagesProvider.notifier).state = [
    ...ref.read(chatMessagesProvider),
    ChatMessage(role: 'assistant', content: response),
  ];

  // Loading aus
  ref.read(isAILoadingProvider.notifier).state = false;
}

void clearChat(WidgetRef ref) {
  final ai = ref.read(nexiiaAIProvider);
  ai.clearHistory();
  ref.read(chatMessagesProvider.notifier).state = [];
}
