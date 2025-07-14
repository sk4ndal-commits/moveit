import '../../domain/entities/journal.dart';

class JournalModel extends Journal {
  JournalModel({
    required int id,
    required int activityId,
    required String content,
    required String mood,
    required DateTime createdAt,
  }) : super(
          id: id,
          activityId: activityId,
          content: content,
          mood: mood,
          createdAt: createdAt,
        );

  // Create a JournalModel from a Map (e.g., from database)
  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map['id'],
      activityId: map['activityId'],
      content: map['content'],
      mood: map['mood'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Convert JournalModel to a Map (e.g., for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'content': content,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy of JournalModel with some changes
  @override
  JournalModel copyWith({
    int? id,
    int? activityId,
    String? content,
    String? mood,
    DateTime? createdAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}