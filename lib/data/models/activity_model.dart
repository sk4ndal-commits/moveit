import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  ActivityModel({
    required int id,
    required String title,
    required String description,
    required String type,
    required int durationMinutes,
    required DateTime date,
    bool isCompleted = false,
    required int userId,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: type,
          durationMinutes: durationMinutes,
          date: date,
          isCompleted: isCompleted,
          userId: userId,
        );

  // Create an ActivityModel from a Map (e.g., from database)
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      durationMinutes: map['durationMinutes'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId'],
    );
  }

  // Convert ActivityModel to a Map (e.g., for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'durationMinutes': durationMinutes,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'userId': userId,
    };
  }

  // Create a copy of ActivityModel with some changes
  @override
  ActivityModel copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    int? durationMinutes,
    DateTime? date,
    bool? isCompleted,
    int? userId,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}