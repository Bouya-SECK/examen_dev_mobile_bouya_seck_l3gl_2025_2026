// lib/screens/tasks/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Écran de création ET modification d'une tâche.
/// Si task est null → mode création
/// Si task est non null → mode modification
class TaskFormScreen extends StatefulWidget {
  /// La tâche à modifier (null si création)
  final Task? task;

  /// L'ID du projet auquel appartient la tâche
  final String projectId;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.projectId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {

  // ==================== CONTROLLERS ET CLÉ ====================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// Statut sélectionné (par défaut : À faire)
  TaskStatus _selectedStatus = TaskStatus.todo;

  /// Priorité sélectionnée (par défaut : Moyenne)
  TaskPriority _selectedPriority = TaskPriority.medium;

  /// Date d'échéance sélectionnée (optionnelle)
  DateTime? _selectedDueDate;

  // ==================== CYCLE DE VIE ====================

  @override
  void initState() {
    super.initState();

    // Si on est en mode modification, on pré-remplit les champs
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ==================== MÉTHODES ====================

  /// Ouvre le sélecteur de date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // Date initiale : date sélectionnée ou aujourd'hui
      initialDate: _selectedDueDate ?? DateTime.now(),
      // Date minimum : aujourd'hui
      firstDate: DateTime.now(),
      // Date maximum : dans 2 ans
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  /// Appelée quand on appuie sur "Créer" ou "Modifier"
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (user == null) return;

    if (widget.task == null) {
      // ---- Mode création ----
      await taskProvider.createTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        projectId: widget.projectId,
        userId: user.id,
        dueDate: _selectedDueDate,
      );
    } else {
      // ---- Mode modification ----
      final Task updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      await taskProvider.updateTask(updated);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  /// Affiche une boîte de dialogue de confirmation avant suppression
  Future<void> _deleteTask() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTask : AppStrings.newTask),
        actions: [
          // Bouton supprimer visible uniquement en mode modification
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outlined, color: AppColors.error),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---- Champ titre ----
              CustomTextField(
                label: AppStrings.taskTitle,
                controller: _titleController,
                hint: 'Ex: Créer la page login',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ---- Champ description ----
              CustomTextField(
                label: AppStrings.taskDescription,
                controller: _descController,
                hint: 'Description détaillée (optionnel)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // ---- Sélecteur de statut ----
              const Text(
                'Statut',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: TaskStatus.values.map((status) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSelectorItem(
                        label: _getStatusLabel(status),
                        color: _getStatusColor(status),
                        isSelected: _selectedStatus == status,
                        onTap: () => setState(() => _selectedStatus = status),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ---- Sélecteur de priorité ----
              const Text(
                'Priorité',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: TaskPriority.values.map((priority) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSelectorItem(
                        label: _getPriorityLabel(priority),
                        color: _getPriorityColor(priority),
                        isSelected: _selectedPriority == priority,
                        onTap: () => setState(() => _selectedPriority = priority),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ---- Sélecteur de date ----
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // Bouton pour ouvrir le sélecteur de date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate != null
                            ? _formatDate(_selectedDueDate!)
                            : 'Sélectionner une date (optionnel)',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textDisable,
                        ),
                      ),
                      const Spacer(),
                      // Bouton pour effacer la date
                      if (_selectedDueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDueDate = null),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ---- Bouton soumettre ----
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  return CustomButton(
                    text: isEditing ? AppStrings.save : AppStrings.add,
                    onPressed: _submit,
                    isLoading: taskProvider.isLoading,
                    icon: isEditing ? Icons.save : Icons.add,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS PRIVÉS ====================

  /// Conteneur animé pour sélectionner un statut ou une priorité
  Widget _buildSelectorItem({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ==================== MÉTHODES UTILITAIRES ====================

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
}