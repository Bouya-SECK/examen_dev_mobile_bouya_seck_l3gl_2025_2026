// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/auth/register_screen.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Écran de connexion de l'application SunuTask.
/// Permet à un utilisateur existant de se connecter.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // ==================== CONTROLLERS ET CLÉ ====================

  /// Clé unique pour identifier et valider notre formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controllers pour lire la valeur de chaque champ
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ==================== CYCLE DE VIE ====================

  @override
  void dispose() {
    // IMPORTANT : toujours libérer les controllers pour éviter les fuites mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==================== MÉTHODES ====================

  /// Appelée quand on appuie sur le bouton "Se connecter"
  Future<void> _login() async {
    // 1. On vérifie que tous les champs sont valides
    if (!_formKey.currentState!.validate()) return;

    // 2. On récupère le provider sans écouter les changements (listen: false)
    // car on est dans une méthode, pas dans le build()
    final AuthProvider authProvider = context.read<AuthProvider>();

    // 3. On appelle la méthode login du provider
    final bool success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // 4. Si le widget est toujours actif dans l'arbre
    if (!mounted) return;

    if (success) {
      // 5. Succès : on navigue vers HomeScreen en supprimant tout l'historique
      // pushAndRemoveUntil empêche l'utilisateur de revenir en arrière
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false, // supprime toutes les routes précédentes
      );
    } else {
      // 6. Échec : on affiche le message d'erreur dans un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? AppStrings.error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // SingleChildScrollView évite le overflow quand le clavier s'ouvre
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ---- Logo et titre ----
                _buildHeader(),

                const SizedBox(height: 48),

                // ---- Champ email ----
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hint: 'exemple@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return AppStrings.invalidEmail;
                    }
                    return null; // null = valide
                  },
                ),

                const SizedBox(height: 16),

                // ---- Champ mot de passe ----
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true, // masque le mot de passe
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ---- Bouton connexion ----
                // Consumer écoute les changements du AuthProvider
                // pour afficher le loader quand isLoading est true
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.login,
                      onPressed: _login,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ---- Lien vers l'inscription ----
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS PRIVÉS ====================

  /// En-tête avec logo et titre
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.task_alt,
            color: Colors.white,
            size: 36,
          ),
        ),

        const SizedBox(height: 24),

        // Titre
        const Text(
          'Bon retour ! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        const Text(
          'Connectez-vous pour accéder à vos projets',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Lien "Pas de compte ? S'inscrire"
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          AppStrings.noAccount,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {
            // Navigation vers RegisterScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: const Text(AppStrings.register),
        ),
      ],
    );
  }
}