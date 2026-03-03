// lib/providers/task_provider.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// TaskProvider gère les tâches avec filtrage et tri.
class TaskProvider extends ChangeNotifier {

  // ==================== PROPRIÉTÉS PRIVÉES ====================

  /// Toutes les tâches chargées (avant filtrage)
  List<Task> _tasks = [];

  /// Filtre actif sur le statut (null = pas de filtre)
  TaskStatus? _statusFilter;

  /// Filtre actif sur la priorité (null = pas de filtre)
  TaskPriority? _priorityFilter;

  bool _isLoading = false;

  // ==================== GETTERS PUBLICS ====================

  bool get isLoading => _isLoading;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Retourne les tâches filtrées ET triées.
  /// Ce getter recalcule la liste à chaque appel.
  List<Task> get tasks {
    List<Task> result = List.from(_tasks);

    // --- Filtrage ---
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    // --- Tri ---
    // D'abord par statut : inProgress(0) > todo(1) > done(2)
    // Ensuite par priorité : high(0) > medium(1) > low(2)
    result.sort((a, b) {
      // On donne un rang numérique à chaque statut
      final int statusOrderA = _statusOrder(a.status);
      final int statusOrderB = _statusOrder(b.status);

      if (statusOrderA != statusOrderB) {
        return statusOrderA.compareTo(statusOrderB);
      }

      // Si même statut, on trie par priorité
      final int priorityOrderA = _priorityOrder(a.priority);
      final int priorityOrderB = _priorityOrder(b.priority);
      return priorityOrderA.compareTo(priorityOrderB);
    });

    return result;
  }

  /// Retourne le nombre de tâches par statut.
  /// Exemple : {TaskStatus.todo: 3, TaskStatus.inProgress: 1, TaskStatus.done: 2}
  Map<TaskStatus, int> get taskCountByStatus {
    final Map<TaskStatus, int> counts = {};

    // On initialise tous les statuts à 0
    for (final TaskStatus status in TaskStatus.values) {
      counts[status] = 0;
    }

    // On compte les tâches par statut
    for (final Task task in _tasks) {
      counts[task.status] = (counts[task.status] ?? 0) + 1;
    }

    return counts;
  }

  // ==================== CLÉ DE STOCKAGE ====================

  static const String _keyTasks = 'tasks';

  // ==================== MÉTHODES CRUD ====================

  /// Charge toutes les tâches d'un projet depuis SharedPreferences.
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    final String? jsonString = StorageService.instance.getString(_keyTasks);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);

        // On filtre uniquement les tâches du projet demandé
        _tasks = decoded
            .map((map) => Task.fromMap(map as Map<String, dynamic>))
            .where((task) => task.projectId == projectId)
            .toList();

      } catch (e) {
        debugPrint('Erreur chargement tâches : $e');
        _tasks = [];
      }
    } else {
      _tasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crée une nouvelle tâche et la sauvegarde.
  Future<void> createTask({
    required String title,
    required String projectId,
    required String userId,
    String? description,
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    final Task newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: status,
      priority: priority,
      projectId: projectId,
      userId: userId,
      dueDate: dueDate,
    );

    _tasks.add(newTask);
    await _saveTasksList();

    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour une tâche existante.
  Future<void> updateTask(Task updatedTask) async {
    _isLoading = true;
    notifyListeners();

    final int index = _tasks.indexWhere((t) => t.id == updatedTask.id);

    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasksList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Supprime une tâche par son ID.
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasksList();

    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour uniquement le statut d'une tâche (changement rapide).
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final int index = _tasks.indexWhere((t) => t.id == taskId);

    if (index != -1) {
      // On utilise copyWith pour ne changer que le statut
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
      await _saveTasksList();
      notifyListeners();
    }
  }

  // ==================== FILTRES ====================

  /// Active un filtre par statut.
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Active un filtre par priorité.
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  /// Supprime tous les filtres actifs.
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Donne un rang numérique au statut pour le tri.
  /// Plus le chiffre est petit, plus la tâche apparaît en premier.
  int _statusOrder(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 0; // En premier
      case TaskStatus.todo:       return 1;
      case TaskStatus.done:       return 2; // En dernier
    }
  }

  /// Donne un rang numérique à la priorité pour le tri.
  int _priorityOrder(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return 0; // En premier
      case TaskPriority.medium: return 1;
      case TaskPriority.low:    return 2; // En dernier
    }
  }

  /// Sauvegarde toute la liste des tâches dans SharedPreferences.
  /// On conserve les tâches des autres projets et on met à jour celles du projet courant.
  Future<void> _saveTasksList() async {
    final String? existingJson = StorageService.instance.getString(_keyTasks);
    List<dynamic> allTasks = [];

    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        allTasks = jsonDecode(existingJson);
      } catch (e) {
        allTasks = [];
      }
    }

    // On supprime les anciennes tâches du projet courant
    if (_tasks.isNotEmpty) {
      final String currentProjectId = _tasks.first.projectId;
      allTasks.removeWhere((map) => map['projectId'] == currentProjectId);
    }

    // On ajoute les tâches mises à jour
    allTasks.addAll(_tasks.map((t) => t.toMap()).toList());

    await StorageService.instance.setString(_keyTasks, jsonEncode(allTasks));
  }
}
