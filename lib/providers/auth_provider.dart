import 'package:flutter/foundation.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Provider qui gère l'authentification (connexion / inscription / déconnexion)
/// Version très simple sans JSON → on stocke les champs un par un
class GestionAuth extends ChangeNotifier {
  // ────────────────────────────────────────────────
  // État actuel
  // ────────────────────────────────────────────────
  User? _utilisateurConnecte;
  bool _chargementEnCours = false;
  String? _messageErreur;

  // Getters (pour que les écrans puissent lire l'état)
  User? get utilisateurConnecte => _utilisateurConnecte;
  bool get estConnecte => _utilisateurConnecte != null;
  bool get chargementEnCours => _chargementEnCours;
  String? get messageErreur => _messageErreur;

  // ────────────────────────────────────────────────
  /// Charge l'utilisateur s'il était déjà connecté (au démarrage)
  Future<void> chargerUtilisateur() async {
    _chargementEnCours = true;
    notifyListeners(); // prévient l'interface qu'on est en train de charger

    // On récupère chaque champ séparément depuis SharedPreferences
    final id = StorageService.instance.getString('auth_id');
    final nom = StorageService.instance.getString('auth_nom');
    final email = StorageService.instance.getString('auth_email');
    final motDePasse = StorageService.instance.getString('auth_mdp');
    final avatar = StorageService.instance.getString('auth_avatar');

    // Si au moins l'email existe → on considère qu'il y a un utilisateur
    if (email != null && email.isNotEmpty) {
      _utilisateurConnecte = User(
        id: id ?? 'user_inconnu',
        name: nom ?? 'Utilisateur',
        email: email,
        password: motDePasse ?? '',
        avatar: avatar,
      );
    }

    _chargementEnCours = false;
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  /// Connexion (simulation très basique pour l'instant)
  Future<bool> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    _chargementEnCours = true;
    _messageErreur = null;
    notifyListeners();

    // Petite attente pour simuler un appel réseau
    await Future.delayed(const Duration(milliseconds: 900));

    // Pour l'instant : on accepte presque tout (à améliorer plus tard)
    // Dans une vraie version on vérifierait si ça correspond à un utilisateur existant
    _utilisateurConnecte = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Utilisateur Test',
      email: email,
      password: motDePasse,
    );

    // Sauvegarde chaque champ séparément
    await StorageService.instance.setString('auth_id', _utilisateurConnecte!.id);
    await StorageService.instance.setString('auth_nom', _utilisateurConnecte!.name);
    await StorageService.instance.setString('auth_email', _utilisateurConnecte!.email);
    await StorageService.instance.setString('auth_mdp', _utilisateurConnecte!.password);
    if (_utilisateurConnecte!.avatar != null) {
      await StorageService.instance.setString('auth_avatar', _utilisateurConnecte!.avatar!);
    }

    _chargementEnCours = false;
    notifyListeners();
    return true;
  }

  // ────────────────────────────────────────────────
  /// Inscription (simulation très basique)
  Future<bool> sinscrire({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    _chargementEnCours = true;
    _messageErreur = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    // Pour l'instant on accepte tout (pas de vérification unicité email)
    _utilisateurConnecte = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: nom,
      email: email,
      password: motDePasse,
    );

    // Sauvegarde
    await StorageService.instance.setString('auth_id', _utilisateurConnecte!.id);
    await StorageService.instance.setString('auth_nom', _utilisateurConnecte!.name);
    await StorageService.instance.setString('auth_email', _utilisateurConnecte!.email);
    await StorageService.instance.setString('auth_mdp', _utilisateurConnecte!.password);

    _chargementEnCours = false;
    notifyListeners();
    return true;
  }

  // ────────────────────────────────────────────────
  /// Déconnexion
  Future<void> seDeconnecter() async {
    _chargementEnCours = true;
    notifyListeners();

    _utilisateurConnecte = null;

    // On supprime toutes les clés liées à l'auth
    await StorageService.instance.remove('auth_id');
    await StorageService.instance.remove('auth_nom');
    await StorageService.instance.remove('auth_email');
    await StorageService.instance.remove('auth_mdp');
    await StorageService.instance.remove('auth_avatar');

    _chargementEnCours = false;
    notifyListeners();
  }

  /// Efface le message d'erreur affiché
  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}