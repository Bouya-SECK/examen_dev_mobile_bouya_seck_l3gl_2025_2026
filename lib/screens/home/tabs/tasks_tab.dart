// lib/screens/home/tabs/tasks_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    if (taskProvider.isLoading) {
      return const LoadingIndicator();
    }

    return Column(
      children: [
        _buildFilterBar(context, taskProvider),
        Expanded(
          child: taskProvider.tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  task: task,
                  // CONNECTÉ : navigation vers le détail de la tâche
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(task: task),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, TaskProvider taskProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Tous',
            isSelected: taskProvider.statusFilter == null,
            onTap: () => taskProvider.clearFilters(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: AppStrings.statusTodo,
            isSelected: taskProvider.statusFilter == TaskStatus.todo,
            onTap: () => taskProvider.setStatusFilter(TaskStatus.todo),
            color: AppColors.statusTodo,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: AppStrings.statusInProgress,
            isSelected: taskProvider.statusFilter == TaskStatus.inProgress,
            onTap: () => taskProvider.setStatusFilter(TaskStatus.inProgress),
            color: AppColors.statusInProgress,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: AppStrings.statusDone,
            isSelected: taskProvider.statusFilter == TaskStatus.done,
            onTap: () => taskProvider.setStatusFilter(TaskStatus.done),
            color: AppColors.statusDone,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 80, color: AppColors.textDisable),
          SizedBox(height: 16),
          Text(
            AppStrings.noTasks,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppStrings.noTasksDesc,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}