import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/database_helper.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final DatabaseHelper _databaseHelper;

  ActivityRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Activity>> getActivitiesByUser(int userId) async {
    final maps = await _databaseHelper.query(
      DatabaseHelper.activityTable,
      whereClause: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  @override
  Future<List<Activity>> getTodayActivities(int userId) async {
    final today = DateTime.now();
    final formattedDate = today.toIso8601String().split('T')[0]; // Get YYYY-MM-DD

    final maps = await _databaseHelper.query(
      DatabaseHelper.activityTable,
      whereClause: 'userId = ? AND date LIKE ?',
      whereArgs: [userId, '$formattedDate%'],
      orderBy: 'date ASC',
    );

    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  @override
  Future<Activity?> getActivity(int id) async {
    final maps = await _databaseHelper.query(
      DatabaseHelper.activityTable,
      whereClause: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return ActivityModel.fromMap(maps.first);
  }

  @override
  Future<Activity> createActivity(Activity activity) async {
    // Convert to ActivityModel if it's not already
    final activityModel = activity is ActivityModel ? activity : ActivityModel(
      id: 0, // Will be replaced by the database
      title: activity.title,
      description: activity.description,
      type: activity.type,
      durationMinutes: activity.durationMinutes,
      date: activity.date,
      isCompleted: activity.isCompleted,
      userId: activity.userId,
    );

    // Insert into database
    final id = await _databaseHelper.insert(
      DatabaseHelper.activityTable,
      activityModel.toMap(),
    );

    // Return the activity with the assigned ID
    return activityModel.copyWith(id: id);
  }

  @override
  Future<Activity> updateActivity(Activity activity) async {
    // Convert to ActivityModel if it's not already
    final activityModel = activity is ActivityModel ? activity : ActivityModel(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      type: activity.type,
      durationMinutes: activity.durationMinutes,
      date: activity.date,
      isCompleted: activity.isCompleted,
      userId: activity.userId,
    );

    // Update in database
    await _databaseHelper.update(
      DatabaseHelper.activityTable,
      activityModel.toMap(),
      'id = ?',
      [activityModel.id],
    );

    return activityModel;
  }

  @override
  Future<Activity> completeActivity(int activityId) async {
    // Get current activity
    final activity = await getActivity(activityId);
    if (activity == null) {
      throw Exception('Activity not found');
    }

    // Mark as completed
    final updatedActivity = ActivityModel(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      type: activity.type,
      durationMinutes: activity.durationMinutes,
      date: activity.date,
      isCompleted: true,
      userId: activity.userId,
    );

    return updateActivity(updatedActivity);
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    await _databaseHelper.delete(
      DatabaseHelper.activityTable,
      'id = ?',
      [activityId],
    );
  }

  @override
  Future<List<Activity>> getActivitiesByDateRange(
    int userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final formattedStartDate = startDate.toIso8601String().split('T')[0];
    final formattedEndDate = endDate.toIso8601String().split('T')[0];

    final maps = await _databaseHelper.query(
      DatabaseHelper.activityTable,
      whereClause: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, formattedStartDate, formattedEndDate + 'T23:59:59'],
      orderBy: 'date ASC',
    );

    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }
}