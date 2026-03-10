// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';

import '../projects/project_form_screen.dart';

/// Écran principal avec navigation par onglets.
/// C'est le premier écran affiché après la connexion.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ==================== PROPRIÉTÉS ====================

  /// Index de l'onglet actuellement sélectionné
  int _currentIndex = 0;

  // ==================== CYCLE DE VIE ====================

  @override
  void initState() {
    super.initState();
    // On charge les données au démarrage du HomeScreen
    _loadData();
  }

  /// Charge les projets et tâches de l'utilisateur connecté
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();

    // On vérifie qu'un utilisateur est bien connecté
    if (authProvider.currentUser == null) return;

    final String userId = authProvider.currentUser!.id;

    // On charge les projets de l'utilisateur
    await context.read<ProjectProvider>().loadProjects(userId);
  }

  // ==================== MÉTHODES ====================

  /// Déconnecte l'utilisateur et redirige vers LoginScreen
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      // ---- AppBar ----
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          // Bouton notification (décoratif pour l'instant)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),

      // ---- Drawer (menu latéral) ----
      drawer: _buildDrawer(user),

      // ---- Corps : IndexedStack garde les onglets en mémoire ----
      // IndexedStack affiche seulement l'onglet actif
      // mais garde tous les autres en mémoire (pas de rechargement)
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardTab(),  // Onglet 0
          ProjectsTab(),   // Onglet 1
          TasksTab(),      // Onglet 2
          ProfileTab(),    // Onglet 3
        ],
      ),

      // ---- Barre de navigation en bas ----
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: AppStrings.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: AppStrings.tasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),

      // ---- Bouton flottant (visible sur Dashboard et Projets) ----
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        // CONNECTÉ : navigation vers le formulaire de création de projet
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProjectFormScreen(),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // ==================== WIDGETS PRIVÉS ====================

  /// Retourne le titre de l'AppBar selon l'onglet actif
  String _getTitle() {
    switch (_currentIndex) {
      case 0: return AppStrings.home;
      case 1: return AppStrings.projects;
      case 2: return AppStrings.tasks;
      case 3: return AppStrings.profile;
      default: return AppStrings.appName;
    }
  }

  /// Construit le menu latéral (Drawer)
  Widget _buildDrawer(user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---- En-tête du Drawer ----
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar avec la première lettre du nom
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(50),
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Nom de l'utilisateur
                Text(
                  user?.name ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Email de l'utilisateur
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),

          // ---- Items de navigation ----
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            label: AppStrings.home,
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.folder_outlined,
            label: AppStrings.projects,
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.checklist_outlined,
            label: AppStrings.tasks,
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.person_outlined,
            label: AppStrings.profile,
            index: 3,
          ),

          const Divider(),

          // ---- Bouton déconnexion ----
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  /// Construit un item du Drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _currentIndex = index);
        // On ferme le Drawer après la sélection
        Navigator.pop(context);
      },
    );
  }
}