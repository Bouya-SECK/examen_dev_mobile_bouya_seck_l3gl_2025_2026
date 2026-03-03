// lib/models/Project.dart

/// Représente un projet dans l'application SunuTask.
/// Ce modèle est IMMUABLE : on ne modifie jamais directement
/// ses champs, on crée une copie avec copyWith().
class Project {

  // ==================== CHAMPS ====================

  /// Identifiant unique du projet (généré avec UUID)
  final String id;

  /// Nom du projet (ex: "Application Mobile")
  final String name;

  /// Description optionnelle (le ? signifie que c'est nullable)
  final String? description;

  /// Couleur du projet stockée en entier (ex: 0xFF0293ED)
  /// On stocke un int car Color n'est pas sérialisable directement
  final int color;

  /// ID de l'utilisateur propriétaire de ce projet
  final String userId;

  /// Date de création (automatique si non fournie)
  final DateTime createdAt;

  // ==================== CONSTRUCTEUR ====================

  Project({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
    this.description,        // optionnel
    DateTime? createdAt,     // optionnel, on met la date actuelle si absent
  }) : createdAt = createdAt ?? DateTime.now();

  // ==================== METHODES ====================

  /// Crée une copie du projet avec certains champs modifiés.
  /// Exemple : final updated = project.copyWith(name: 'Nouveau nom');
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

  /// Convertit le projet en Map pour le sauvegarder dans SharedPreferences.
  /// SharedPreferences ne peut pas stocker des objets directement,
  /// donc on transforme tout en types simples (String, int, bool...).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'userId': userId,
      // toIso8601String() convertit DateTime en texte ex: "2025-03-01T10:00:00"
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Recrée un objet Project depuis une Map lue dans SharedPreferences.
  /// C'est un constructeur "factory" : il peut retourner une instance existante
  /// ou en créer une nouvelle.
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
      userId: map['userId'] as String,
      // DateTime.parse() reconvertit le texte en DateTime
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId)';
  }
}
