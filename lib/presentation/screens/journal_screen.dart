import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/models/activity_model.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/journal.dart';
import '../providers/activity_provider.dart';
import '../providers/journal_provider.dart';
import '../providers/user_provider.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: journalProvider.isLoading || activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalProvider.journals.isEmpty
              ? const Center(
                  child: Text(
                    'No journal entries yet. Add your first entry!',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => journalProvider.loadJournalsForUser(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: journalProvider.journals.length,
                    itemBuilder: (context, index) {
                      final journal = journalProvider.journals[index];
                      // Find the activity for this journal
                      final activity = activityProvider.activities.firstWhere(
                        (a) => a.id == journal.activityId,
                        orElse: () => ActivityModel(
                          id: -1,
                          title: 'Unknown Activity',
                          description: '',
                          type: 'Unknown',
                          durationMinutes: 0,
                          date: DateTime.now(),
                          userId: -1,
                        ),
                      );

                      return _buildJournalCard(
                        context, 
                        journal, 
                        activity,
                        onEdit: () => _showJournalDialog(context, activity, journal),
                        onDelete: () => _deleteJournal(context, journal),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectActivityForJournal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build a card for a journal entry
  Widget _buildJournalCard(
    BuildContext context, 
    Journal journal, 
    Activity activity, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  journal.formattedDate,
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(activity.type),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(journal.mood),
                  backgroundColor: _getMoodColor(journal.mood).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getMoodColor(journal.mood)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              journal.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get color based on mood
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return Colors.blue;
      case 'good':
        return Colors.blue[400]!;
      case 'neutral':
        return Colors.blue[300]!;
      case 'tired':
        return Colors.blue[600]!;
      case 'exhausted':
        return Colors.blue[800]!;
      default:
        return Colors.blue[200]!;
    }
  }

  // Show dialog to select an activity for a new journal entry
  Future<void> _selectActivityForJournal(BuildContext context) async {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    // Get completed activities
    final completedActivities = activityProvider.activities
        .where((activity) => activity.isCompleted)
        .toList();

    if (completedActivities.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to complete an activity before adding a journal entry.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return;
    }

    final selectedActivity = await showDialog<Activity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Activity'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: completedActivities.length,
            itemBuilder: (context, index) {
              final activity = completedActivities[index];
              return ListTile(
                title: Text(activity.title),
                subtitle: Text(
                  '${activity.type} - ${DateFormat('yyyy-MM-dd').format(activity.date)}',
                ),
                onTap: () => Navigator.of(context).pop(activity),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );

    if (selectedActivity != null && context.mounted) {
      _showJournalDialog(context, selectedActivity);
    }
  }

  // Show dialog to add or edit a journal entry
  Future<void> _showJournalDialog(
    BuildContext context, 
    Activity activity, 
    [Journal? journal]
  ) async {
    final formKey = GlobalKey<FormState>();
    final contentController = TextEditingController(text: journal?.content ?? '');
    String selectedMood = journal?.mood ?? Moods.good;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(journal == null ? 'Add Journal Entry' : 'Edit Journal Entry'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity: ${activity.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${activity.type} - ${DateFormat('yyyy-MM-dd').format(activity.date)}',
                    style: TextStyle(color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 16),
                  const Text('How did you feel?'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: Moods.values.map((mood) {
                      return ChoiceChip(
                        label: Text(mood),
                        selected: selectedMood == mood,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedMood = mood;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Journal Entry',
                      border: OutlineInputBorder(),
                      hintText: 'Write about your experience...',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
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
                  final journalProvider = Provider.of<JournalProvider>(context, listen: false);
                  final userProvider = Provider.of<UserProvider>(context, listen: false);

                  if (journal == null) {
                    // Create new journal entry
                    await journalProvider.createJournal(
                      activityId: activity.id,
                      content: contentController.text,
                      mood: selectedMood,
                    );

                    // Award XP for creating a journal entry
                    if (userProvider.currentUser != null) {
                      await userProvider.addXp(5); // 5 XP for journaling
                    }
                  } else {
                    // Update existing journal entry
                    await journalProvider.updateJournal(
                      journal.copyWith(
                        content: contentController.text,
                        mood: selectedMood,
                      ),
                    );
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          journal == null
                              ? 'Journal entry created'
                              : 'Journal entry updated',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete a journal entry
  Future<void> _deleteJournal(BuildContext context, Journal journal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal Entry'),
        content: const Text('Are you sure you want to delete this journal entry?'),
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
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final success = await journalProvider.deleteJournal(journal.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Journal entry deleted' : 'Failed to delete journal entry',
            ),
            backgroundColor: success ? Colors.blue : Colors.blue[800],
          ),
        );
      }
    }
  }
}
