import 'package:flutter/foundation.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/repositories/user_repository.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _activityRepository;
  final UserRepository _userRepository;
  
  List<Activity> _activities = [];
  List<Activity> _todayActivities = [];
  bool _isLoading = false;
  String? _error;
  int? _currentUserId;

  ActivityProvider(this._activityRepository, this._userRepository);

  // Getters
  List<Activity> get activities => _activities;
  List<Activity> get todayActivities => _todayActivities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current user ID
  void setUserId(int userId) {
    _currentUserId = userId;
    loadActivities();
  }

  // Load all activities for current user
  Future<void> loadActivities() async {
    if (_currentUserId == null) return;
    
    _setLoading(true);
    try {
      _activities = await _activityRepository.getActivitiesByUser(_currentUserId!);
      _todayActivities = await _activityRepository.getTodayActivities(_currentUserId!);
      _setError(null);
    } catch (e) {
      _setError('Failed to load activities: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new activity
  Future<Activity?> createActivity({
    required String title,
    required String description,
    required String type,
    required int durationMinutes,
    required DateTime date,
  }) async {
    if (_currentUserId == null) return null;
    
    _setLoading(true);
    try {
      final activity = Activity(
        id: 0, // Will be replaced by the database
        title: title,
        description: description,
        type: type,
        durationMinutes: durationMinutes,
        date: date,
        isCompleted: false,
        userId: _currentUserId!,
      );
      
      final createdActivity = await _activityRepository.createActivity(activity);
      
      // Reload activities to update the lists
      await loadActivities();
      
      _setError(null);
      return createdActivity;
    } catch (e) {
      _setError('Failed to create activity: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing activity
  Future<Activity?> updateActivity(Activity activity) async {
    _setLoading(true);
    try {
      final updatedActivity = await _activityRepository.updateActivity(activity);
      
      // Reload activities to update the lists
      await loadActivities();
      
      _setError(null);
      return updatedActivity;
    } catch (e) {
      _setError('Failed to update activity: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Mark activity as completed and award XP
  Future<Activity?> completeActivity(int activityId) async {
    if (_currentUserId == null) return null;
    
    _setLoading(true);
    try {
      final activity = await _activityRepository.getActivity(activityId);
      if (activity == null) {
        _setError('Activity not found');
        return null;
      }
      
      // Mark as completed
      final completedActivity = await _activityRepository.completeActivity(activityId);
      
      // Award XP based on duration (1 XP per minute)
      await _userRepository.addXp(_currentUserId!, activity.durationMinutes);
      
      // Update total sport hours
      await _userRepository.updateTotalSportHours(
        _currentUserId!, 
        activity.durationHours
      );
      
      // Reload activities to update the lists
      await loadActivities();
      
      _setError(null);
      return completedActivity;
    } catch (e) {
      _setError('Failed to complete activity: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete an activity
  Future<bool> deleteActivity(int activityId) async {
    _setLoading(true);
    try {
      await _activityRepository.deleteActivity(activityId);
      
      // Reload activities to update the lists
      await loadActivities();
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete activity: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get activities for a specific date range
  Future<List<Activity>> getActivitiesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    if (_currentUserId == null) return [];
    
    _setLoading(true);
    try {
      final activities = await _activityRepository.getActivitiesByDateRange(
        _currentUserId!,
        startDate,
        endDate
      );
      _setError(null);
      return activities;
    } catch (e) {
      _setError('Failed to get activities by date range: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    if (errorMessage != null) {
      notifyListeners();
    }
  }
}