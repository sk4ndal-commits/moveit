class AppConstants {
  // App name
  static const String appName = 'MoveIt';
  
  // Bottom navigation bar items
  static const String dashboardLabel = 'Dashboard';
  static const String activitiesLabel = 'Activities';
  static const String journalLabel = 'Journal';
  
  // Activity types
  static const List<String> activityTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Swimming',
    'Gym',
    'Yoga',
    'Other'
  ];
  
  // XP constants
  static const int xpPerMinute = 1;
  static const int xpForJournalEntry = 5;
  
  // Level thresholds
  static int xpRequiredForLevel(int level) {
    return level * 100;
  }
}