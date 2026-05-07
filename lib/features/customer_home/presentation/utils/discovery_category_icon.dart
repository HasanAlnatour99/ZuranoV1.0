import 'package:flutter/material.dart';

IconData discoveryCategoryIcon(String iconKey) {
  switch (iconKey.trim().toLowerCase()) {
    case 'beard':
      return Icons.face_retouching_natural_outlined;
    case 'scissors':
    case 'haircut':
      return Icons.content_cut_rounded;
    case 'fade':
      return Icons.person_outline_rounded;
    case 'facial':
      return Icons.spa_outlined;
    case 'spa':
    case 'hair_spa':
      return Icons.water_drop_outlined;
    case 'massage':
      return Icons.self_improvement_outlined;
    case 'nails':
      return Icons.back_hand_outlined;
    default:
      return Icons.auto_awesome_outlined;
  }
}
