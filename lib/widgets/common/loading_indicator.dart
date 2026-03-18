// lib/widgets/common/loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

/// Un indicateur de chargement réutilisable.
/// On l'utilise partout où on attend une réponse (chargement de données, etc.)
class LoadingIndicator extends StatelessWidget {
  /// Taille du cercle de chargement (par défaut 24)
  final double size;

  /// Couleur du cercle (par défaut la couleur principale de l'app)
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            // Si une couleur est fournie on l'utilise, sinon on prend la couleur principale
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}