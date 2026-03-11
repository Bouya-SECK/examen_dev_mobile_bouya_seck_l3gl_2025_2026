// lib/screens/home/tabs/dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

/// Onglet tableau de bord : vue d'ensemble de l'activité
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  /// Retourne un message de bienvenue selon l'heure
  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final user = authProvider.currentUser;
    final taskCounts = taskProvider.taskCountByStatus;

    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await projectProvider.loadProjects(user.id);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---- Message de bienvenue ----
            Text(
              '${_getGreeting()}, ${user?.name ?? ''} ',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Voici un résumé de votre activité',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // ---- Cartes de statistiques ----
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Projets',
                    value: projectProvider.projectCount.toString(),
                    icon: Icons.folder,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'À faire',
                    value: (taskCounts[TaskStatus.todo] ?? 0).toString(),
                    icon: Icons.radio_button_unchecked,
                    color: AppColors.statusTodo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'En cours',
                    value: (taskCounts[TaskStatus.inProgress] ?? 0).toString(),
                    icon: Icons.timelapse,
                    color: AppColors.statusInProgress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Terminées',
                    value: (taskCounts[TaskStatus.done] ?? 0).toString(),
                    icon: Icons.check_circle,
                    color: AppColors.statusDone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---- Projets récents ----
            const Text(
              'Projets récents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Si pas de projets : message vide
            if (projectProvider.projects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aucun projet pour l\'instant.\nAppuyez sur + pour créer un projet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
            // On affiche les 3 derniers projets
              ...projectProvider.projects.take(3).map(
                    (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProjectCard(
                    project: project,
                    taskCount: 0,
                    // Navigation vers le détail du projet
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Carte de statistique réutilisable
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}