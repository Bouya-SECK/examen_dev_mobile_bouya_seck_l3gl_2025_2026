// lib/models/Project.dart

/*
  Représente un projet dans l'application SunuTask.
  Ce modèle est IMMUABLE : on ne modifie jamais directement
  ses champs, on crée une copie avec copyWith().
 */

class Project {

  final String id;
  final String name;
  final String? description;
  final int color;
  final String userId;
  final DateTime createdAt;

  // ==================== CONSTRUCTEUR ====================

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ==================== METHODES ====================

  Project copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    String? userId,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /*
    Convertit le projet en Map pour le sauvegarder dans SharedPreferences.
    SharedPreferences ne peut pas stocker des objets directement,
    donc on transforme tout en types simples.
   */

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /*
    Recrée un objet Project depuis une Map lue dans SharedPreferences.
    C'est un constructeur "factory" : il peut retourner une instance existante
    ou en créer une nouvelle.
   */

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
      userId: map['userId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId)';
  }
}
