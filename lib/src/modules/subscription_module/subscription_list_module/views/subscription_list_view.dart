import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/custom_widgets/empty_state_widget.dart';
import '../controller/subscription_list_controller.dart';
import '../widgets/subscription_list_tile.dart';

class SubscriptionListView extends GetView<SubscriptionListController> {
  const SubscriptionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.0,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppConstants.navSubscriptions,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 26, color: AppColors.primary),
            onPressed: controller.openAddSubscription,
            tooltip: 'Add Subscription',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: controller.searchController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppConstants.searchSubscriptionsHint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          controller.searchController.clear();
                        },
                      );
                    }),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Chips Row
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Obx(() => Row(
                              children: controller.filterOptions.map((filter) {
                                final isSelected = controller.selectedFilter.value == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    selected: isSelected,
                                    label: Text(filter),
                                    onSelected: (val) => controller.setFilter(filter),
                                    backgroundColor: isDark
                                        ? AppColors.darkSurfaceSecondary
                                        : AppColors.lightSurfaceSecondary,
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary),
                                    ),
                                    showCheckmark: false,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                );
                              }).toList(),
                            )),
                      ),
                    ),

                    // Sort Button Menu
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.sort_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: controller.setSort,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'date',
                          child: Text('Next Renewal Date'),
                        ),
                        const PopupMenuItem(
                          value: 'price_desc',
                          child: Text('Price: High to Low'),
                        ),
                        const PopupMenuItem(
                          value: 'price_asc',
                          child: Text('Price: Low to High'),
                        ),
                        const PopupMenuItem(
                          value: 'name',
                          child: Text('Alphabetical (A-Z)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 2. Subscription List
          Expanded(
            child: Obx(() {
              final list = controller.filteredSubscriptions;

              if (list.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: AppConstants.emptySubscriptionsTitle,
                  description: controller.searchQuery.value.isNotEmpty
                      ? 'No subscriptions match "${controller.searchQuery.value}".'
                      : AppConstants.emptySubscriptionsDesc,
                  buttonText: 'Add Subscription',
                  onButtonPressed: controller.openAddSubscription,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final sub = list[index];
                  return SubscriptionListTile(
                    subscription: sub,
                    onTap: () => controller.openEditSubscription(sub),
                    onToggleStatus: () => controller.toggleSubscriptionStatus(sub.id),
                    onDelete: () => controller.deleteSubscription(sub.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
