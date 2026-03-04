// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

/// Un bouton personnalisé avec deux variantes : plein ou contour.
/// On l'utilise partout dans l'app pour avoir un style cohérent.
class CustomButton extends StatelessWidget {
  /// Le texte affiché sur le bouton
  final String text;

  /// La fonction appelée quand on appuie (null = bouton désactivé)
  final VoidCallback? onPressed;

  /// Si true, affiche un loader à la place du texte
  final bool isLoading;

  /// Si true, affiche un bouton avec contour (OutlinedButton)
  /// Si false, affiche un bouton plein (ElevatedButton)
  final bool isOutlined;

  /// Icône optionnelle affichée à gauche du texte
  final IconData? icon;

  /// Largeur optionnelle (par défaut prend toute la largeur)
  final double? width;

  /// Hauteur optionnelle (par défaut 52)
  final double height;

  /// Couleur optionnelle (par défaut couleur principale)
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,     // par défaut pas de loader
    this.isOutlined = false,    // par défaut bouton plein
    this.icon,
    this.width,
    this.height = 52,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // La couleur utilisée : celle fournie ou la couleur principale
    final Color buttonColor = color ?? AppColors.primary;

    // Le contenu du bouton : loader OU icône+texte
    final Widget buttonChild = isLoading
        ? LoadingIndicator(size: 22, color: isOutlined ? buttonColor : Colors.white)
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Affiche l'icône seulement si elle est fournie
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    // Le style commun aux deux variantes
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(width ?? double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    // On retourne le bon type de bouton selon isOutlined
    if (isOutlined) {
      return OutlinedButton(
        // Si isLoading est true, on désactive le bouton (onPressed = null)
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: buttonChild,
      );
    }

    // Bouton plein (ElevatedButton)
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          // Si le bouton est désactivé, on assombrit la couleur
          if (states.contains(WidgetState.disabled)) {
            return buttonColor.withAlpha(150);
          }
          return buttonColor;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: buttonChild,
    );
  }
}