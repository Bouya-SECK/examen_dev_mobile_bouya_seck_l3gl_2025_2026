import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sunu_task/core/theme/app_theme.dart';
import 'package:sunu_task/screens/splash/splash_screen.dart';
import 'package:sunu_task/services/storage_service.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  runApp(const SunuTask());
}

class SunuTask extends StatelessWidget {
  const SunuTask({super.key});

  @override
  Widget build(BuildContext context) {
    /// On enveloppe MaterialApp dans MultiProvider pour que
    /// tous les widgets de l'app aient accès aux providers
    return MultiProvider(
      providers: [
        // Gère l'état global (onboarding, initialisation)
        ChangeNotifierProvider(create: (_) => AppProvider()),

        // Gère la connexion et l'utilisateur courant
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Gère la liste des projets
        ChangeNotifierProvider(create: (_) => ProjectProvider()),

        // Gère la liste des tâches
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'SunuTask',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}