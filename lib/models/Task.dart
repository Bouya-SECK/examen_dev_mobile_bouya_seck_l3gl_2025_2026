// lib/models/Task.dart


enum TaskStatus {
  todo,
  inProgress,
  done,
}

// Les niveaux de priorité d'une tâche.
enum TaskPriority {
  low,
  medium,
  high,
}


class Task {

  // ==================== CHAMPS ====================

  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String userId;
  final DateTime? dueDate;
  final DateTime createdAt;

  // ==================== CONSTRUCTEUR ====================

  Task({
    required this.id,
    required this.title,
    required this.projectId,
    required this.userId,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ==================== METHODES ====================

  // Crée une copie de la tache avec certains champs modifiés.
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

  // Convertit la tâche en Map pour SharedPreferences.
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
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Recrée un objet Task depuis une Map lue dans SharedPreferences.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,

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
