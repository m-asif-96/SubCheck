import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';

class BrandAvatar extends StatelessWidget {
  final String name;
  final SubscriptionCategory category;
  final String? brandColorHex;
  final double size;
  final double borderRadius;

  const BrandAvatar({
    super.key,
    required this.name,
    required this.category,
    this.brandColorHex,
    this.size = 46.0,
    this.borderRadius = 14.0,
  });

  Color _parseColor() {
    if (brandColorHex != null && brandColorHex!.isNotEmpty) {
      try {
        final hex = brandColorHex!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          category.icon,
          size: size * 0.48,
          color: color,
        ),
      ),
    );
  }
}
