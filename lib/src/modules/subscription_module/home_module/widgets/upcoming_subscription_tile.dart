import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/subscription_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/custom_widgets/brand_avatar.dart';
import '../../../../core/utils/custom_widgets/custom_card.dart';

class UpcomingSubscriptionTile extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onTap;

  const UpcomingSubscriptionTile({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = subscription.daysUntilPayment;

    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (days == 0) {
      badgeBg = AppColors.danger.withValues(alpha: 0.12);
      badgeFg = AppColors.danger;
      badgeText = 'Due Today';
    } else if (days <= 3) {
      badgeBg = AppColors.warning.withValues(alpha: 0.14);
      badgeFg = AppColors.warning;
      badgeText = 'In $days days';
    } else {
      badgeBg = (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary);
      badgeFg = (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
      badgeText = 'In $days days';
    }

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      child: Row(
        children: [
          // Logo / Brand Avatar
          BrandAvatar(
            name: subscription.name,
            category: subscription.category,
            brandColorHex: subscription.brandColorHex,
            size: 46,
          ),
          const SizedBox(width: 14),

          // Name and Due Date Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subscription.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        CurrencyFormatter.formatShortDate(subscription.nextPaymentDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Price & Cycle
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subscription.currencySymbol}${subscription.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '/${subscription.billingCycle.shortLabel}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
