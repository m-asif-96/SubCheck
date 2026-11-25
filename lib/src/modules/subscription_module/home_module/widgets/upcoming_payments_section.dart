import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/subscription_model.dart';
import '../../../../core/utils/custom_widgets/empty_state_widget.dart';
import 'upcoming_subscription_tile.dart';

class UpcomingPaymentsSection extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final VoidCallback onSeeAllTap;
  final Function(SubscriptionModel) onSubscriptionTap;
  final VoidCallback onAddTap;

  const UpcomingPaymentsSection({
    super.key,
    required this.subscriptions,
    required this.onSeeAllTap,
    required this.onSubscriptionTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.upcomingPaymentsTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${subscriptions.length} due in the next 30 days',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.seeAll,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // List or Empty State
        if (subscriptions.isEmpty)
          EmptyStateWidget(
            icon: Icons.calendar_today_outlined,
            title: 'No upcoming renewals',
            description: 'You have no payments due in the next 30 days.',
            buttonText: 'Add Subscription',
            onButtonPressed: onAddTap,
          )
        else
          ListView.builder(
            itemCount: subscriptions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return UpcomingSubscriptionTile(
                subscription: sub,
                onTap: () => onSubscriptionTap(sub),
              );
            },
          ),
      ],
    );
  }
}
