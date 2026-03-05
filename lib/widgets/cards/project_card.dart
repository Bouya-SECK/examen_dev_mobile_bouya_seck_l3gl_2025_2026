// lib/widgets/cards/project_card.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

/// Carte affichant les informations résumées d'un projet.
/// Utilisée dans la liste des projets et le dashboard.
class ProjectCard extends StatelessWidget {
  /// Le projet à afficher
  final Project project;

  /// Nombre de tâches du projet (passé depuis le provider)
  final int taskCount;

  /// Fonction appelée quand on appuie sur la carte
  final VoidCallback? onTap;

  /// Fonction appelée quand on appuie sur "Modifier"
  final VoidCallback? onEdit;

  /// Fonction appelée quand on appuie sur "Supprimer"
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // On recrée la couleur depuis l'entier stocké dans le projet
    final Color projectColor = Color(project.color);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // InkWell ajoute l'effet de ripple quand on appuie
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ---- Pastille de couleur du projet ----
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // On utilise la couleur du projet avec une opacité légère
                  color: projectColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.folder,
                  color: projectColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // ---- Nom et description ----
              Expanded(
                // Expanded prend tout l'espace disponible
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      // Si le nom est trop long, on coupe avec "..."
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (project.description != null &&
                        project.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // ---- Nombre de tâches ----
                    Row(
                      children: [
                        const Icon(
                          Icons.task_alt,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$taskCount tâche${taskCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---- Menu contextuel (3 points) ----
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit?.call(); // appelle onEdit si elle n'est pas null
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}