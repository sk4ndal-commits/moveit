import 'package:intl/intl.dart';

class Activity {
  final int id;
  final String title;
  final String description;
  final String type;
  final int durationMinutes;
  final DateTime date;
  final bool isCompleted;
  final int userId;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.date,
    this.isCompleted = false,
    required this.userId,
  });

  // Get duration in hours (for statistics)
  double get durationHours => durationMinutes / 60;

  // Format date for display
  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  // Check if activity is scheduled for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    int? durationMinutes,
    DateTime? date,
    bool? isCompleted,
    int? userId,
  }) {
    return Activity(
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