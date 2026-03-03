// lib/models/Task.dart

/// Les statuts possibles d'une tâche.
/// Un enum est une liste fixe de valeurs nommées.
enum TaskStatus {
  todo,        // À faire
  inProgress,  // En cours
  done,        // Terminée
}

/// Les niveaux de priorité d'une tâche.
enum TaskPriority {
  low,     // Basse
  medium,  // Moyenne
  high,    // Haute
}

/// Représente une tâche dans l'application SunuTask.
/// Une tâche appartient toujours à un projet (via projectId).
class Task {

  // ==================== CHAMPS ====================

  /// Identifiant unique de la tâche (généré avec UUID)
  final String id;

  /// Titre de la tâche (ex: "Créer la page login")
  final String title;

  /// Description détaillée, optionnelle
  final String? description;

  /// Statut actuel : todo, inProgress ou done
  final TaskStatus status;

  /// Niveau de priorité : low, medium ou high
  final TaskPriority priority;

  /// ID du projet auquel appartient cette tâche
  final String projectId;

  /// ID de l'utilisateur qui a créé la tâche
  final String userId;

  /// Date limite optionnelle
  final DateTime? dueDate;

  /// Date de création
  final DateTime createdAt;

  // ==================== CONSTRUCTEUR ====================

  Task({
    required this.id,
    required this.title,
    required this.projectId,
    required this.userId,
    this.description,
    this.status = TaskStatus.todo,       // valeur par défaut : "À faire"
    this.priority = TaskPriority.medium, // valeur par défaut : "Moyenne"
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ==================== METHODES ====================

  /// Crée une copie de la tâche avec certains champs modifiés.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? userId,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertit la tâche en Map pour SharedPreferences.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // .name convertit l'enum en String : TaskStatus.todo → "todo"
      'status': status.name,
      'priority': priority.name,
      'projectId': projectId,
      'userId': userId,
      // dueDate est optionnel donc on vérifie avant de convertir
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Recrée un objet Task depuis une Map lue dans SharedPreferences.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      // firstWhere cherche l'enum dont le .name correspond à la valeur sauvegardée
      // orElse est le fallback si la valeur n'est pas trouvée
      status: TaskStatus.values.firstWhere(
            (s) => s.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
            (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: ${status.name})';
  }
}
