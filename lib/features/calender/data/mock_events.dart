import 'package:flutter/material.dart';
import '../models/nexiia_event.dart';

List<NexiiaEvent> buildMockEvents() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    NexiiaEvent(
        id: '1',
        title: 'Team Standup',
        subtitle: 'Mit Felix & Sarah',
        location: 'Zoom',
        start: today.add(const Duration(hours: 9)),
        end: today.add(const Duration(hours: 9, minutes: 30)),
        color: const Color(0xFF818CF8)),
    NexiiaEvent(
        id: '2',
        title: 'Deep Work – Nexiia UI',
        subtitle: 'Kein Slack, kein Mail',
        start: today.add(const Duration(hours: 10)),
        end: today.add(const Duration(hours: 12)),
        color: const Color(0xFF60A5FA),
        energyLevel: 0.85),
    NexiiaEvent(
        id: '3',
        title: 'Mittagspause',
        start: today.add(const Duration(hours: 12)),
        end: today.add(const Duration(hours: 13)),
        color: const Color(0xFF34D399)),
    NexiiaEvent(
        id: '4',
        title: 'Investor Call',
        subtitle: 'Series A Vorbereitung',
        location: 'Konferenzraum B',
        start: today.add(const Duration(hours: 14)),
        end: today.add(const Duration(hours: 15)),
        color: const Color(0xFFF59E0B),
        energyLevel: 0.95),
    NexiiaEvent(
        id: '5',
        title: 'Fokusblock · KI',
        subtitle: 'Von Nexiia vorgeschlagen',
        start: today.add(const Duration(hours: 16)),
        end: today.add(const Duration(hours: 17, minutes: 30)),
        color: const Color(0xFF60A5FA),
        energyLevel: 0.7,
        isAiSuggested: true),
    NexiiaEvent(
        id: '6',
        title: 'Design Review',
        subtitle: 'Figma Walkthrough',
        start: today.add(const Duration(days: 1, hours: 10)),
        end: today.add(const Duration(days: 1, hours: 11)),
        color: const Color(0xFFA78BFA)),
    NexiiaEvent(
        id: '7',
        title: 'Sprint Planning',
        start: today.add(const Duration(days: 2, hours: 9)),
        end: today.add(const Duration(days: 2, hours: 11)),
        color: const Color(0xFFF87171)),
    NexiiaEvent(
        id: '8',
        title: 'User Research',
        start: today.add(const Duration(days: 3, hours: 14)),
        end: today.add(const Duration(days: 3, hours: 16)),
        color: const Color(0xFF34D399)),
    NexiiaEvent(
        id: '9',
        title: 'Weekly Review',
        start: today.add(const Duration(days: 4, hours: 17)),
        end: today.add(const Duration(days: 4, hours: 18)),
        color: const Color(0xFF60A5FA),
        energyLevel: 0.5),
    NexiiaEvent(
        id: '10',
        title: 'Boxtraining',
        start: today.add(const Duration(days: 3, hours: 18)),
        end: today.add(const Duration(days: 3, hours: 19)),
        color: const Color(0xFFF87171)),
  ];
}
