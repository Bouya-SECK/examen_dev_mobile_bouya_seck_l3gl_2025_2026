// lib/widgets/cards/task_card.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

/// Carte affichant les informations résumées d'une tâche.
/// Utilisée dans la liste des tâches et le détail d'un projet.
class TaskCard extends StatelessWidget {
  /// La tâche à afficher
  final Task task;

  /// Fonction appelée quand on appuie sur la carte
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Ligne du haut : titre + badge statut ----
              Row(
                children: [
                  // Indicateur de priorité (barre colorée à gauche)
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Titre de la tâche
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        // Si la tâche est terminée, on barre le texte
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Badge de statut
                  _buildStatusBadge(task.status),
                ],
              ),

              // ---- Description (si elle existe) ----
              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    task.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // ---- Ligne du bas : priorité + date ----
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    // Indicateur de priorité (icône + texte)
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: _getPriorityColor(task.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityLabel(task.priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPriorityColor(task.priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Date d'échéance (si elle existe)
                    if (task.dueDate != null) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          // Rouge si la date est dépassée
                          color: _isOverdue(task.dueDate!)
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Retourne la couleur selon le statut de la tâche
  Widget _buildStatusBadge(TaskStatus status) {
    final Color color;
    final String label;

    switch (status) {
      case TaskStatus.todo:
        color = AppColors.statusTodo;
        label = 'À faire';
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        label = 'En cours';
        break;
      case TaskStatus.done:
        color = AppColors.statusDone;
        label = 'Terminé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Retourne la couleur selon la priorité
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }

  /// Retourne le label selon la priorité
  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return 'Haute';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.low:    return 'Basse';
    }
  }

  /// Formate une date en texte lisible (ex: "15 Mar 2026")
  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Vérifie si la date d'échéance est dépassée
  bool _isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate) && task.status != TaskStatus.done;
  }
}