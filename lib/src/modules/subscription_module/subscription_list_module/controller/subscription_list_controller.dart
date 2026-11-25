import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/main_app_controller/main_app_controller.dart';
import '../../../../core/common/widgets/custom_snack_bar.dart';
import '../../../../core/models/subscription_model.dart';
import '../../../../core/routes/app_pages.dart';

class SubscriptionListController extends GetxController {
  final MainAppController _mainApp = Get.find<MainAppController>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs; // All, Active, Cancelled
  final selectedSort = 'date'.obs; // date, price_desc, price_asc, name

  final filterOptions = const ['All', 'Active', 'Cancelled'];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSort(String sort) {
    selectedSort.value = sort;
  }

  List<SubscriptionModel> get filteredSubscriptions {
    final query = searchQuery.value;
    final filter = selectedFilter.value;

    var list = _mainApp.subscriptions.where((item) {
      // 1. Status Filter
      if (filter == 'Active' && !item.isActive) return false;
      if (filter == 'Cancelled' && item.isActive) return false;

      // 2. Query Search
      if (query.isNotEmpty) {
        final matchesName = item.name.toLowerCase().contains(query);
        final matchesCategory = item.category.label.toLowerCase().contains(query);
        final matchesNotes = item.notes?.toLowerCase().contains(query) ?? false;
        return matchesName || matchesCategory || matchesNotes;
      }
      return true;
    }).toList();

    // Sorting
    switch (selectedSort.value) {
      case 'price_desc':
        list.sort((a, b) => b.monthlyEquivalent.compareTo(a.monthlyEquivalent));
        break;
      case 'price_asc':
        list.sort((a, b) => a.monthlyEquivalent.compareTo(b.monthlyEquivalent));
        break;
      case 'name':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'date':
      default:
        list.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
        break;
    }

    return list;
  }

  void openEditSubscription(SubscriptionModel subscription) {
    Get.toNamed(AppRoutes.editSubscription, arguments: subscription);
  }

  void openAddSubscription() {
    Get.toNamed(AppRoutes.addSubscription);
  }

  Future<void> toggleSubscriptionStatus(String id) async {
    try {
      await _mainApp.toggleSubscriptionActive(id);
      CustomSnackBar.showInfo('Subscription status updated');
    } catch (e) {
      CustomSnackBar.showError('Could not update status');
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await _mainApp.deleteSubscription(id);
      CustomSnackBar.showSuccess('Subscription deleted');
    } catch (e) {
      CustomSnackBar.showError('Could not delete subscription');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
