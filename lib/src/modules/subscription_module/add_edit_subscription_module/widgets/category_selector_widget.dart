import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/subscription_model.dart';

class CategorySelectorWidget extends StatelessWidget {
  final SubscriptionCategory selected;
  final ValueChanged<SubscriptionCategory> onSelect;

  const CategorySelectorWidget({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: SubscriptionCategory.values.map((cat) {
        final isSelected = cat == selected;

        return InkWell(
          onTap: () => onSelect(cat),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: isDark ? 0.25 : 0.15)
                  : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? cat.color
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 16,
                  color: isSelected
                      ? cat.color
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : cat.color)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
