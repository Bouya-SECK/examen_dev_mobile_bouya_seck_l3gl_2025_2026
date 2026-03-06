// lib/screens/home/tabs/projects_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

/// Onglet liste des projets
class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    // Affiche un loader pendant le chargement
    if (projectProvider.isLoading) {
      return const LoadingIndicator();
    }

    // Affiche un message si la liste est vide
    if (projectProvider.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 80,
              color: AppColors.textDisable,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noProjects,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noProjectsDesc,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateProjectDialog(context, user?.id ?? ''),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.newProject),
            ),
          ],
        ),
      );
    }

    // Affiche la liste des projets
    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await projectProvider.loadProjects(user.id);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projectProvider.projects.length,
        itemBuilder: (context, index) {
          final project = projectProvider.projects[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProjectCard(
              project: project,
              taskCount: 0,
              onTap: () {},
              onEdit: () {},
              onDelete: () => _confirmDelete(context, projectProvider, project.id),
            ),
          );
        },
      ),
    );
  }

  /// Affiche une boîte de dialogue pour créer un projet
  void _showCreateProjectDialog(BuildContext context, String userId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    int selectedColor = AppColors.primary.value;

    // Liste de 8 couleurs prédéfinies
    final List<int> colors = [
      AppColors.primary.value,
      AppColors.secondary.value,
      AppColors.error.value,
      AppColors.warning.value,
      AppColors.success.value,
      AppColors.primaryDark.value,
      const Color(0xFF9C27B0).value,
      const Color(0xFFFF9800).value,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(AppStrings.newProject),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Champ nom
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.projectName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Champ description
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.projectDescription,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Sélecteur de couleur
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Couleur :'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colors.map((colorValue) {
                      final bool isSelected = selectedColor == colorValue;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = colorValue),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  await context.read<ProjectProvider>().createProject(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    color: selectedColor,
                    userId: userId,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(AppStrings.add),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant suppression
  void _confirmDelete(
      BuildContext context,
      ProjectProvider projectProvider,
      String projectId,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await projectProvider.deleteProject(projectId);
              if (context.mounted) Navigator.pop(context);
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
}