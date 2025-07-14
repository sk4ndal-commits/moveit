class User {
  final int id;
  final String name;
  final int xp;
  final int level;
  final int totalSportHours;

  User({
    required this.id,
    required this.name,
    this.xp = 0,
    this.level = 1,
    this.totalSportHours = 0,
  });

  User copyWith({
    int? id,
    String? name,
    int? xp,
    int? level,
    int? totalSportHours,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      totalSportHours: totalSportHours ?? this.totalSportHours,
    );
  }
}