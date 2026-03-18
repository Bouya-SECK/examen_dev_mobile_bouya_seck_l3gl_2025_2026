// lib/screens/projects/project_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Écran de création ET modification d'un projet.
/// Si project est null → mode création
/// Si project est non null → mode modification
class ProjectFormScreen extends StatefulWidget {
  /// Le projet à modifier (null si création)
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {

  // ==================== CONTROLLERS ET CLÉ ====================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// Couleur sélectionnée (par défaut : couleur principale)
  int _selectedColor = AppColors.primary.value;

  /// Les 8 couleurs prédéfinies proposées à l'utilisateur
  final List<int> _colors = [
    AppColors.primary.value,
    AppColors.secondary.value,
    AppColors.error.value,
    AppColors.warning.value,
    AppColors.success.value,
    AppColors.primaryDark.value,
    const Color(0xFF9C27B0).value, // Violet
    const Color(0xFFFF9800).value, // Orange
  ];

  // ==================== CYCLE DE VIE ====================

  @override
  void initState() {
    super.initState();

    // Si on est en mode modification, on pré-remplit les champs
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ==================== MÉTHODES ====================

  /// Appelée quand on appuie sur le bouton "Créer" ou "Modifier"
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final projectProvider = context.read<ProjectProvider>();
    final user = context.read<AuthProvider>().currentUser;

    if (user == null) return;

    if (widget.project == null) {
      // ---- Mode création ----
      await projectProvider.createProject(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
        userId: user.id,
      );
    } else {
      // ---- Mode modification ----
      // On utilise copyWith pour ne modifier que les champs changés
      final Project updated = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
      );
      await projectProvider.updateProject(updated);
    }

    if (!mounted) return;
    // On revient à l'écran précédent
    Navigator.pop(context);
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    // On vérifie si on est en mode création ou modification
    final bool isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editProject : AppStrings.newProject),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---- Champ nom ----
              CustomTextField(
                label: AppStrings.projectName,
                controller: _nameController,
                hint: 'Ex: Application Mobile',
                prefixIcon: Icons.folder_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (value.length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ---- Champ description ----
              CustomTextField(
                label: AppStrings.projectDescription,
                controller: _descController,
                hint: 'Description du projet (optionnel)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // ---- Sélecteur de couleur ----
              const Text(
                'Couleur du projet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Wrap affiche les cercles de couleur en les wrappant
              // automatiquement à la ligne si nécessaire
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((colorValue) {
                  final bool isSelected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorValue),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        // Bordure visible si la couleur est sélectionnée
                        border: isSelected
                            ? Border.all(color: AppColors.textPrimary, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(
                          color: Color(colorValue).withAlpha(150),
                          blurRadius: 8,
                        )]
                            : null,
                      ),
                      // Icône check si sélectionné
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ---- Aperçu en temps réel ----
              const Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // On affiche un aperçu du projet avec les valeurs actuelles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(_selectedColor).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(_selectedColor).withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(_selectedColor).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder,
                        color: Color(_selectedColor),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Affiche le nom saisi en temps réel
                          ValueListenableBuilder(
                            valueListenable: _nameController,
                            builder: (context, value, child) {
                              return Text(
                                _nameController.text.isEmpty
                                    ? 'Nom du projet'
                                    : _nameController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _nameController.text.isEmpty
                                      ? AppColors.textDisable
                                      : AppColors.textPrimary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '0 tâche',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ---- Bouton soumettre ----
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, child) {
                  return CustomButton(
                    text: isEditing ? AppStrings.save : AppStrings.add,
                    onPressed: _submit,
                    isLoading: projectProvider.isLoading,
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
}