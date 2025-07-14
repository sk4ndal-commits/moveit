import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required int id,
    required String name,
    int xp = 0,
    int level = 1,
    int totalSportHours = 0,
  }) : super(
          id: id,
          name: name,
          xp: xp,
          level: level,
          totalSportHours: totalSportHours,
        );

  // Create a UserModel from a Map (e.g., from database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      totalSportHours: map['totalSportHours'] ?? 0,
    );
  }

  // Convert UserModel to a Map (e.g., for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'xp': xp,
      'level': level,
      'totalSportHours': totalSportHours,
    };
  }

  // Create a copy of UserModel with some changes
  @override
  UserModel copyWith({
    int? id,
    String? name,
    int? xp,
    int? level,
    int? totalSportHours,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      totalSportHours: totalSportHours ?? this.totalSportHours,
    );
  }
}