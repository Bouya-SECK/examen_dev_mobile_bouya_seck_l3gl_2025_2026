import 'package:flutter/foundation.dart'; // Pour ChangeNotifier
import 'package:sunu_task/services/storage_service.dart';

/// AppProvider : gère l'état global de l'application
/// (onboarding terminé ou pas, si l'app est initialisée, etc.)
class AppProvider extends ChangeNotifier
{
  // ==================== PROPRIÉTÉS PRIVÉES ====================
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  // ==================== GETTERS PUBLICS ====================
  // Ces getters permettent aux widgets de lire l'état
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // ==================== MÉTHODES ====================

  /// Initialise l'application au démarrage
  /// Charge l'état de l'onboarding depuis le stockage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners(); // Met à jour l'UI (affiche un loader par exemple)

    // On initialise le StorageService (comme dans le onboarding_screen)
    await StorageService.instance.init();

    // On récupère la valeur sauvegardée
    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;
    _isInitialized = true;
    _isLoading = false;

    notifyListeners(); // Met à jour l'UI avec les nouvelles valeurs
  }

  /// Marque l'onboarding comme terminé et le sauvegarde
  Future<void> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    _isLoading = false;

    notifyListeners();
  }

  /// Réinitialise l'onboarding (utile pour les tests ou debug)
  Future<void> resetOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.setOnboardingComplete(false);
    _isOnboardingComplete = false;
    _isLoading = false;

    notifyListeners();
  }
}