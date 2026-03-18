// lib/providers/project_provider.dart

import 'dart:convert'; // Pour jsonEncode et jsonDecode

import 'package:flutter/foundation.dart'; // Pour ChangeNotifier
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart'; // Pour générer les IDs uniques

/// ProjectProvider gère la liste des projets de l'utilisateur.
/// Il étend ChangeNotifier pour notifier les widgets quand les données changent.
class ProjectProvider extends ChangeNotifier {

  // ==================== PROPRIÉTÉS PRIVÉES ====================

  /// La liste de tous les projets chargés en mémoire
  List<Project> _projects = [];

  /// Le projet actuellement sélectionné (pour la navigation)
  Project? _selectedProject;

  /// Indique si une opération est en cours (afficher un loader)
  bool _isLoading = false;

  // ==================== GETTERS PUBLICS ====================
  // Les widgets lisent ces valeurs mais ne peuvent pas les modifier directement

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;

  /// Retourne le nombre total de projets
  int get projectCount => _projects.length;

  // ==================== CLÉ DE STOCKAGE ====================

  /// La clé utilisée pour sauvegarder dans SharedPreferences
  static const String _keyProjects = 'projects';

  // ==================== MÉTHODES ====================

  /// Charge tous les projets d'un utilisateur depuis SharedPreferences.
  /// On filtre par userId pour n'avoir que les projets de cet utilisateur.
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners(); // Notifie les widgets → affiche le loader

    // On récupère la chaîne JSON sauvegardée
    final String? jsonString = StorageService.instance.getString(_keyProjects);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        // jsonDecode transforme le texte JSON en liste Dart
        final List<dynamic> decoded = jsonDecode(jsonString);

        // On convertit chaque Map en objet Project et on filtre par userId
        _projects = decoded
            .map((map) => Project.fromMap(map as Map<String, dynamic>))
            .where((project) => project.userId == userId)
            .toList();

      } catch (e) {
        debugPrint('Erreur chargement projets : $e');
        _projects = [];
      }
    } else {
      // Pas de données sauvegardées : liste vide
      _projects = [];
    }

    _isLoading = false;
    notifyListeners(); // Notifie les widgets → affiche la liste
  }

  /// Crée un nouveau projet et le sauvegarde.
  Future<void> createProject({
    required String name,
    required int color,
    required String userId,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    // On crée un nouvel objet Project avec un ID unique généré par UUID
    final Project newProject = Project(
      id: const Uuid().v4(), // génère un ID unique ex: "a1b2-c3d4-..."
      name: name,
      description: description,
      color: color,
      userId: userId,
    );

    // On ajoute à la liste en mémoire
    _projects.add(newProject);

    // On sauvegarde toute la liste dans SharedPreferences
    await _saveProjectsList();

    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour un projet existant.
  Future<void> updateProject(Project updatedProject) async {
    _isLoading = true;
    notifyListeners();

    // On cherche l'index du projet à modifier dans la liste
    final int index = _projects.indexWhere((p) => p.id == updatedProject.id);

    if (index != -1) {
      // On remplace le projet à cet index
      _projects[index] = updatedProject;
      await _saveProjectsList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Supprime un projet par son ID.
  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    // removeWhere supprime tous les éléments qui correspondent à la condition
    _projects.removeWhere((p) => p.id == projectId);

    await _saveProjectsList();

    _isLoading = false;
    notifyListeners();
  }

  /// Sélectionne un projet (pour la navigation vers le détail).
  /// Passer null pour désélectionner.
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  // ==================== MÉTHODE PRIVÉE ====================

  /// Sauvegarde toute la liste des projets en JSON dans SharedPreferences.
  /// Cette méthode est privée (commence par _) car elle est interne au provider.
  Future<void> _saveProjectsList() async {
    // On récupère TOUS les projets déjà sauvegardés (tous utilisateurs)
    final String? existingJson = StorageService.instance.getString(_keyProjects);
    List<dynamic> allProjects = [];

    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        allProjects = jsonDecode(existingJson);
      } catch (e) {
        allProjects = [];
      }
    }

    // On récupère l'userId du premier projet de notre liste (si elle n'est pas vide)
    if (_projects.isNotEmpty) {
      final String currentUserId = _projects.first.userId;

      // On supprime les anciens projets de cet utilisateur
      allProjects.removeWhere((map) => map['userId'] == currentUserId);
    }

    // On ajoute les projets mis à jour
    allProjects.addAll(_projects.map((p) => p.toMap()).toList());

    // On sauvegarde tout en JSON
    final String jsonString = jsonEncode(allProjects);
    await StorageService.instance.setString(_keyProjects, jsonString);
  }
}