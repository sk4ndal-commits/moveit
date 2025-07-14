import 'package:flutter/material.dart';
import '../../domain/entities/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildTypeChip(context),
              ],
            ),
            if (activity.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  decoration: activity.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${activity.durationMinutes} min',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  activity.formattedDate,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!activity.isCompleted && onComplete != null)
                    ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (activity.isCompleted)
                    Chip(
                      label: const Text('Completed'),
                      backgroundColor: Colors.green[100],
                      labelStyle: TextStyle(color: Colors.green[800]),
                    ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    Color chipColor;
    switch (activity.type.toLowerCase()) {
      case 'running':
        chipColor = Colors.blue;
        break;
      case 'walking':
        chipColor = Colors.green;
        break;
      case 'cycling':
        chipColor = Colors.orange;
        break;
      case 'swimming':
        chipColor = Colors.cyan;
        break;
      case 'gym':
        chipColor = Colors.red;
        break;
      case 'yoga':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(activity.type),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor),
    );
  }
}