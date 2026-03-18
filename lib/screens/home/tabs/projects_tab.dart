// lib/screens/home/tabs/projects_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    if (projectProvider.isLoading) {
      return const LoadingIndicator();
    }

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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProjectFormScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.newProject),
            ),
          ],
        ),
      );
    }

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
              // CONNECTÉ : navigation vers le détail du projet
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(project: project),
                ),
              ),
              // CONNECTÉ : navigation vers le formulaire de modification
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(project: project),
                ),
              ),
              onDelete: () => _confirmDelete(
                context,
                projectProvider,
                project.id,
              ),
            ),
          );
        },
      ),
    );
  }

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