import 'package:flutter/material.dart';

class NexiiaEvent {
  final String id;
  String title;
  String? subtitle;
  String? location;
  DateTime start;
  DateTime end;
  Color color;
  double? energyLevel;
  bool isAiSuggested;

  NexiiaEvent({
    required this.id,
    required this.title,
    this.subtitle,
    this.location,
    required this.start,
    required this.end,
    required this.color,
    this.energyLevel,
    this.isAiSuggested = false,
  });

  int get durationMinutes => end.difference(start).inMinutes;

  NexiiaEvent copy() => NexiiaEvent(
        id: id,
        title: title,
        subtitle: subtitle,
        location: location,
        start: start,
        end: end,
        color: color,
        energyLevel: energyLevel,
        isAiSuggested: isAiSuggested,
      );
}