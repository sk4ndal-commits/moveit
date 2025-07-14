import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/database_helper.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepositoryImpl(this._databaseHelper);

  @override
  Future<User?> getUser(int id) async {
    final maps = await _databaseHelper.query(
      DatabaseHelper.userTable,
      whereClause: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserModel.fromMap(maps.first);
  }

  @override
  Future<User> createUser(String name) async {
    // Create a new user with default values
    final user = UserModel(
      id: 0, // Will be replaced by the database
      name: name,
      xp: 0,
      level: 1,
      totalSportHours: 0,
    );

    // Insert into database
    final id = await _databaseHelper.insert(
      DatabaseHelper.userTable,
      user.toMap(),
    );

    // Return the user with the assigned ID
    return user.copyWith(id: id);
  }

  @override
  Future<User> updateUser(User user) async {
    // Convert to UserModel if it's not already
    final userModel = user is UserModel ? user : UserModel(
      id: user.id,
      name: user.name,
      xp: user.xp,
      level: user.level,
      totalSportHours: user.totalSportHours,
    );

    // Update in database
    await _databaseHelper.update(
      DatabaseHelper.userTable,
      userModel.toMap(),
      'id = ?',
      [userModel.id],
    );

    return userModel;
  }

  @override
  Future<User> addXp(int userId, int xpAmount) async {
    // Get current user
    final user = await getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Calculate new XP and level
    int newXp = user.xp + xpAmount;
    int newLevel = user.level;
    
    // Simple level up logic: level up every 100 XP
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel++;
    }

    // Update user
    final updatedUser = UserModel(
      id: user.id,
      name: user.name,
      xp: newXp,
      level: newLevel,
      totalSportHours: user.totalSportHours,
    );

    return updateUser(updatedUser);
  }

  @override
  Future<User> updateTotalSportHours(int userId, double additionalHours) async {
    // Get current user
    final user = await getUser(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Update total sport hours
    final updatedUser = UserModel(
      id: user.id,
      name: user.name,
      xp: user.xp,
      level: user.level,
      totalSportHours: user.totalSportHours + additionalHours.round(),
    );

    return updateUser(updatedUser);
  }
}