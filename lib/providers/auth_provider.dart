import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {

  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  // A appeler une fois au démarrage de l'application
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Charger tous les utilisateurs
    final jsonString = StorageService.instance.getString('users');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _users = decoded.map((map) => User.fromMap(map as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Erreur lors du chargement des utilisateurs : $e');
      }
    }

    // Charger l'utilisateur actuellement connecté
    final currentId = StorageService.instance.getString('current_user_id');
    if (currentId != null) {
      try {
        _currentUser = _users.firstWhere((u) => u.id == currentId);
      } catch (_) {
        // Pas trouvé → on reste déconnecté
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Connexion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final foundUser = _users.firstWhere(
          (user) => user.email == email && user.password == password,
      orElse: () => null as User,
    );

    if (foundUser != null) {
      _currentUser = foundUser;
      await StorageService.instance.setString('current_user_id', foundUser.id);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = "Email ou mot de passe incorrect";
    _isLoading = false;
    notifyListeners();
    return false;
  }


  // Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Vérifier unicité email
    if (_users.any((u) => u.email == email)) {
      _errorMessage = "Cet email est déjà utilisé";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Créer nouvel utilisateur
    final newId = const Uuid().v4();
    final newUser = User(
      id: newId,
      name: name,
      email: email,
      password: password,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    _currentUser = newUser;

    // Sauvegarder la liste complète
    await _saveUsersList();

    // Marquer comme connecté
    await StorageService.instance.setString('current_user_id', newId);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // methode de deconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = null;
    await StorageService.instance.remove('current_user_id');

    _isLoading = false;
    notifyListeners();
  }


  // Sauvegarde la liste entière des utilisateurs en JSON
  Future<void> _saveUsersList() async {
    final jsonString = jsonEncode(
      _users.map((user) => user.toMap()).toList(),
    );
    await StorageService.instance.setString('users', jsonString);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}