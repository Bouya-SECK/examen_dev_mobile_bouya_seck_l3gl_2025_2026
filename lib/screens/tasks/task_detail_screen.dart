// lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';

/// Écran de détail d'une tâche avec possibilité de changer le statut rapidement
class TaskDetailScreen extends StatelessWidget {
  /// La tâche à afficher
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la tâche'),
        actions: [
          // Bouton modifier
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(
                    task: task,
                    projectId: task.projectId,
                  ),
                ),
              );
            },
          ),
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outlined, color: AppColors.error),
            onPressed: () => _deleteTask(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---- Titre ----
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // ---- Description ----
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ---- Changement rapide de statut ----
            const Text(
              'Statut',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: TaskStatus.values.map((status) {
                final bool isSelected = task.status == status;
                final Color color = _getStatusColor(status);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () async {
                        // Changement rapide de statut
                        await context
                            .read<TaskProvider>()
                            .updateTaskStatus(task.id, status);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(30)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? color
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ---- Priorité ----
            const Text(
              'Priorité',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: _getPriorityColor(task.priority),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPriorityLabel(task.priority),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(task.priority),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---- Date d'échéance ----
            if (task.dueDate != null) ...[
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: _isOverdue(task.dueDate!)
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 15,
                      color: _isOverdue(task.dueDate!)
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_isOverdue(task.dueDate!)) ...[
                    const SizedBox(width: 8),
                    const Text(
                      '(En retard)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
            ],

            // ---- Date de création ----
            Text(
              'Créée le ${_formatDate(task.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDisable,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MÉTHODES ====================

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await context.read<TaskProvider>().deleteTask(task.id);
              if (!context.mounted) return;
              Navigator.pop(context); // ferme le dialog
              Navigator.pop(context); // revient en arrière
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:       return 'À faire';
      case TaskStatus.inProgress: return 'En cours';
      case TaskStatus.done:       return 'Terminée';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:       return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done:       return AppColors.statusDone;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return 'Haute';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.low:    return 'Basse';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate) && task.status != TaskStatus.done;
  }
}