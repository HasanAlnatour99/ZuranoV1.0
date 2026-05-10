import 'package:flutter/material.dart';

/// Maps CMS `iconKey` values to Material icons for square category tiles.
IconData zuranoCategoryIcon(String rawKey) {
  switch (rawKey.trim().toLowerCase()) {
    case 'hair':
    case 'haircut':
    case 'scissors':
      return Icons.content_cut_rounded;
    case 'barber':
    case 'barbers':
    case 'beard':
      return Icons.face_retouching_natural_rounded;
    case 'nails':
      return Icons.brush_rounded;
    case 'spa':
    case 'hair_spa':
      return Icons.spa_rounded;
    case 'facial':
    case 'beauty':
      return Icons.self_improvement_rounded;
    case 'massage':
      return Icons.back_hand_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}
