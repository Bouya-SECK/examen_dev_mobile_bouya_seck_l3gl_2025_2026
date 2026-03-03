import 'package:flutter/foundation.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère l'état global de l'application (onboarding, chargement, etc.)
class GestionApp extends ChangeNotifier {
  // --- État privé ---
  bool _onboardingTermine = false;
  bool _initialise = false;
  bool _enChargement = false;

  // --- Getters (pour lire l'état depuis les écrans) ---
  bool get onboardingTermine => _onboardingTermine;
  bool get initialise => _initialise;
  bool get enChargement => _enChargement;

  /// Initialise l'application au démarrage
  Future<void> initialiser() async {
    _enChargement = true;
    notifyListeners();

    // On s'assure que le service de stockage est prêt
    await StorageService.instance.init();

    // On lit si l'onboarding a déjà été vu
    _onboardingTermine = StorageService.instance.isOnboardingComplete;

    _initialise = true;
    _enChargement = false;

    notifyListeners();
  }

  /// Marque l'onboarding comme terminé et sauvegarde
  Future<void> terminerOnboarding() async {
    _enChargement = true;
    notifyListeners();

    await StorageService.instance.setOnboardingComplete(true);
    _onboardingTermine = true;
    _enChargement = false;

    notifyListeners();
  }

  /// (Optionnel - utile pour tester) Réinitialise l'onboarding
  Future<void> reinitialiserOnboarding() async {
    _enChargement = true;
    notifyListeners();

    await StorageService.instance.setOnboardingComplete(false);
    _onboardingTermine = false;
    _enChargement = false;

    notifyListeners();
  }
}