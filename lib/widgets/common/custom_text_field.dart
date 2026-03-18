// lib/widgets/common/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

/// Un champ de texte personnalisé avec support de validation.
/// C'est un StatefulWidget car il gère l'affichage/masquage du mot de passe.
class CustomTextField extends StatefulWidget {
  /// Le label affiché au-dessus du champ
  final String label;

  /// Le controller pour lire/modifier la valeur du champ
  final TextEditingController? controller;

  /// Le texte d'indication quand le champ est vide
  final String? hint;

  /// La fonction de validation (retourne null si valide, un message si invalide)
  final String? Function(String?)? validator;

  /// Si true, le texte est masqué (pour les mots de passe)
  final bool obscureText;

  /// Le type de clavier à afficher (email, nombre, texte, etc.)
  final TextInputType? keyboardType;

  /// Icône optionnelle à gauche du champ
  final IconData? prefixIcon;

  /// Nombre de lignes (par défaut 1, mettre plus pour une description)
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,  // par défaut texte visible
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// Gère si le mot de passe est visible ou non
  /// On commence par masquer le mot de passe (true)
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label au-dessus du champ
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Le champ de texte
        TextFormField(
          controller: widget.controller,
          // Si obscureText est true ET qu'on n'a pas appuyé sur l'oeil
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,

            // Icône à gauche si fournie
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
                : null,

            // Icône oeil à droite UNIQUEMENT pour les champs mot de passe
            suffixIcon: widget.obscureText
                ? IconButton(
              onPressed: () {
                // On inverse la valeur de _isObscured
                setState(() => _isObscured = !_isObscured);
              },
              icon: Icon(
                // On change l'icône selon l'état
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }
}