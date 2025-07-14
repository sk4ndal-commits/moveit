import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/activity.dart';
import '../providers/user_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    // Show loading indicator if data is still loading
    if (userProvider.isLoading || activityProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show error if there's an issue
    if (userProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${userProvider.error}'),
        ),
      );
    }
    
    final user = userProvider.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user found. Please restart the app.'),
        ),
      );
    }
    
    // Calculate XP progress
    final xpRequired = AppConstants.xpRequiredForLevel(user.level);
    final xpProgress = user.xp / xpRequired;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await activityProvider.loadActivities();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hello, ${user.name}!',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              'Lv${user.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Total Sport Hours: ${user.totalSportHours}'),
                      const SizedBox(height: 8),
                      Text('XP: ${user.xp}/${xpRequired}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Today's activities
              Text(
                "Today's Activities",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              
              if (activityProvider.todayActivities.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No activities scheduled for today. Add some in the Activities tab!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityProvider.todayActivities.length,
                  itemBuilder: (context, index) {
                    final activity = activityProvider.todayActivities[index];
                    return ActivityCard(
                      activity: activity,
                      onComplete: () => _completeActivity(context, activity),
                    );
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Activity stats
              Text(
                'Activity Stats',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 200,
                child: _buildActivityStats(context, activityProvider.activities),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Complete an activity
  Future<void> _completeActivity(BuildContext context, Activity activity) async {
    if (activity.isCompleted) return;
    
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    await activityProvider.completeActivity(activity.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity completed! You earned ${activity.durationMinutes} XP.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  // Build activity stats chart
  Widget _buildActivityStats(BuildContext context, List<Activity> activities) {
    // Group activities by type
    final Map<String, double> activityByType = {};
    
    for (final activity in activities) {
      if (activity.isCompleted) {
        final type = activity.type;
        activityByType[type] = (activityByType[type] ?? 0) + activity.durationHours;
      }
    }
    
    // If no completed activities, show a message
    if (activityByType.isEmpty) {
      return const Card(
        child: Center(
          child: Text('Complete activities to see your stats!'),
        ),
      );
    }
    
    // Create pie chart sections
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    
    int colorIndex = 0;
    activityByType.forEach((type, hours) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: hours,
          title: '$type\n${hours.toStringAsFixed(1)}h',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }
}