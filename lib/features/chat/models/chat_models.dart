// ═══════════════════════════════════════════════════════════════════════════════
// NEXIIA CHAT — Data Models
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Einzelne Nachricht in einem Chat
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus { sending, sent, error }

/// Ein Chat-Thread (Konversation)
class ChatThread {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatThread({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Letzter Nachrichten-Text für Preview
  String get lastMessagePreview {
    if (messages.isEmpty) return 'Neuer Chat';
    final last = messages.last;
    if (last.text.length > 60) return '${last.text.substring(0, 60)}…';
    return last.text;
  }

  /// Ob der letzte Absender die AI war
  bool get lastWasAi => messages.isNotEmpty && !messages.last.isUser;
}

/// Vorschlags-Chip für den Welcome-State
class SuggestionChip {
  final String label;
  final IconData icon;
  final String prompt;

  const SuggestionChip({
    required this.label,
    required this.icon,
    required this.prompt,
  });
}

/// Mock-Vorschläge
const List<SuggestionChip> kDefaultSuggestions = [
  SuggestionChip(
    label: 'Tagesplan erstellen',
    icon: Icons.calendar_today_rounded,
    prompt: 'Erstelle mir einen produktiven Tagesplan für heute.',
  ),
  SuggestionChip(
    label: 'Motivation',
    icon: Icons.bolt_rounded,
    prompt: 'Gib mir einen motivierenden Impuls für den Tag.',
  ),
  SuggestionChip(
    label: 'Ideen brainstormen',
    icon: Icons.lightbulb_outline_rounded,
    prompt: 'Hilf mir beim Brainstorming für ein neues Projekt.',
  ),
  SuggestionChip(
    label: 'Fokus verbessern',
    icon: Icons.center_focus_strong_rounded,
    prompt: 'Wie kann ich meine Konzentration heute verbessern?',
  ),
  SuggestionChip(
    label: 'Mail schreiben',
    icon: Icons.mail_outline_rounded,
    prompt: 'Hilf mir eine professionelle E-Mail zu formulieren.',
  ),
  SuggestionChip(
    label: 'Zusammenfassung',
    icon: Icons.auto_stories_rounded,
    prompt: 'Fasse mir folgendes zusammen:',
  ),
];