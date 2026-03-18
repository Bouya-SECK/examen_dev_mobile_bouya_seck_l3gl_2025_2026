// lib/screens/projects/project_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

/// Écran de détail d'un projet avec la liste de ses tâches
class ProjectDetailScreen extends StatefulWidget {
  /// Le projet à afficher
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  @override
  void initState() {
    super.initState();
    // On charge les tâches du projet au démarrage
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await context.read<TaskProvider>().loadTasks(widget.project.id);
  }

  // ==================== MÉTHODES ====================

  /// Navigue vers le formulaire de modification
  void _editProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(project: widget.project),
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant suppression
  void _deleteProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: const Text(
          'Supprimer ce projet supprimera aussi toutes ses tâches. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              // On supprime le projet
              await context.read<ProjectProvider>().deleteProject(widget.project.id);
              // On supprime toutes les tâches du projet
              await context.read<TaskProvider>().deleteTasksByProjectId(widget.project.id);

              if (!mounted) return;
              // On ferme le dialog puis on revient en arrière
              Navigator.pop(context); // ferme le dialog
              Navigator.pop(context); // revient à la liste
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

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final taskCounts = taskProvider.taskCountByStatus;
    final Color projectColor = Color(widget.project.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          // Bouton modifier
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editProject,
          ),
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outlined, color: AppColors.error),
            onPressed: _deleteProject,
          ),
        ],
      ),

      // ---- Bouton flottant pour ajouter une tâche ----
      floatingActionButton: FloatingActionButton(
        backgroundColor: projectColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(projectId: widget.project.id),
            ),
          ).then((_) => _loadTasks()); // Recharge les tâches au retour
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: taskProvider.isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---- En-tête coloré ----
            _buildHeader(projectColor),

            // ---- Liste des tâches ----
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tâches (${taskProvider.tasks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // État vide
                  if (taskProvider.tasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Aucune tâche.\nAppuyez sur + pour en ajouter une.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...taskProvider.tasks.map(
                          (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          onTap: () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// En-tête coloré avec nom, description, date et chips de statistiques
  Widget _buildHeader(Color projectColor) {
    final taskProvider = context.watch<TaskProvider>();
    final taskCounts = taskProvider.taskCountByStatus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: projectColor.withAlpha(30),
        border: Border(
          bottom: BorderSide(color: projectColor.withAlpha(80)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du projet
          Text(
            widget.project.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: projectColor,
            ),
          ),

          // Description
          if (widget.project.description != null &&
              widget.project.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.project.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Date de création
          Text(
            'Créé le ${_formatDate(widget.project.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDisable,
            ),
          ),

          const SizedBox(height: 16),

          // Chips de statistiques par statut
          Wrap(
            spacing: 8,
            children: [
              _buildStatChip(
                label: 'À faire',
                count: taskCounts[TaskStatus.todo] ?? 0,
                color: AppColors.statusTodo,
              ),
              _buildStatChip(
                label: 'En cours',
                count: taskCounts[TaskStatus.inProgress] ?? 0,
                color: AppColors.statusInProgress,
              ),
              _buildStatChip(
                label: 'Terminées',
                count: taskCounts[TaskStatus.done] ?? 0,
                color: AppColors.statusDone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Chip affichant le nombre de tâches par statut
  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}