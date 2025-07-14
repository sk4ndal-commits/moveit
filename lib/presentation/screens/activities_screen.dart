import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_card.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : activityProvider.activities.isEmpty
              ? const Center(
                  child: Text('No activities yet. Add your first activity!'),
                )
              : RefreshIndicator(
                  onRefresh: () => activityProvider.loadActivities(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: activityProvider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = activityProvider.activities[index];
                      return ActivityCard(
                        activity: activity,
                        onComplete: !activity.isCompleted
                            ? () => _completeActivity(context, activity)
                            : null,
                        onEdit: () => _showActivityDialog(context, activity),
                        onDelete: () => _deleteActivity(context, activity),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActivityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Complete an activity
  Future<void> _completeActivity(BuildContext context, Activity activity) async {
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

  // Delete an activity
  Future<void> _deleteActivity(BuildContext context, Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final success = await activityProvider.deleteActivity(activity.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Activity deleted' : 'Failed to delete activity',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // Show dialog to add or edit an activity
  Future<void> _showActivityDialog(BuildContext context, [Activity? activity]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: activity?.title ?? '');
    final descriptionController = TextEditingController(text: activity?.description ?? '');
    String selectedType = activity?.type ?? AppConstants.activityTypes.first;
    final durationController = TextEditingController(
      text: activity?.durationMinutes.toString() ?? '30',
    );
    DateTime selectedDate = activity?.date ?? DateTime.now();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity == null ? 'Add Activity' : 'Edit Activity'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Activity Type',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.activityTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Please enter a valid duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        selectedDate.hour,
                        selectedDate.minute,
                      );
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
                
                if (activity == null) {
                  // Create new activity
                  await activityProvider.createActivity(
                    title: titleController.text,
                    description: descriptionController.text,
                    type: selectedType,
                    durationMinutes: int.parse(durationController.text),
                    date: selectedDate,
                  );
                } else {
                  // Update existing activity
                  await activityProvider.updateActivity(
                    activity.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      type: selectedType,
                      durationMinutes: int.parse(durationController.text),
                      date: selectedDate,
                    ),
                  );
                }
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        activity == null
                            ? 'Activity created'
                            : 'Activity updated',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}