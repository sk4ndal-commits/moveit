import 'package:intl/intl.dart';

class Journal {
  final int id;
  final int activityId;
  final String content;
  final String mood;
  final DateTime createdAt;

  Journal({
    required this.id,
    required this.activityId,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  // Format date for display
  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

  Journal copyWith({
    int? id,
    int? activityId,
    String? content,
    String? mood,
    DateTime? createdAt,
  }) {
    return Journal(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Enum-like class for mood options
class Moods {
  static const String great = 'Great';
  static const String good = 'Good';
  static const String neutral = 'Neutral';
  static const String tired = 'Tired';
  static const String exhausted = 'Exhausted';
  
  static List<String> values = [great, good, neutral, tired, exhausted];
}