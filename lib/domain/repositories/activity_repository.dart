import '../entities/activity.dart';

abstract class ActivityRepository {
  // Get all activities for a user
  Future<List<Activity>> getActivitiesByUser(int userId);
  
  // Get activities for today
  Future<List<Activity>> getTodayActivities(int userId);
  
  // Get activity by ID
  Future<Activity?> getActivity(int id);
  
  // Create a new activity
  Future<Activity> createActivity(Activity activity);
  
  // Update an activity
  Future<Activity> updateActivity(Activity activity);
  
  // Mark activity as completed
  Future<Activity> completeActivity(int activityId);
  
  // Delete an activity
  Future<void> deleteActivity(int activityId);
  
  // Get activities by date range
  Future<List<Activity>> getActivitiesByDateRange(
    int userId, 
    DateTime startDate, 
    DateTime endDate
  );
}