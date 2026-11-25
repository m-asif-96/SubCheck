import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BillingCycle {
  weekly('Weekly', 'wk'),
  monthly('Monthly', 'mo'),
  yearly('Yearly', 'yr'),
  custom('Custom', 'custom');

  final String label;
  final String shortLabel;
  const BillingCycle(this.label, this.shortLabel);

  static BillingCycle fromString(String value) {
    return BillingCycle.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BillingCycle.monthly,
    );
  }
}

enum SubscriptionCategory {
  entertainment('Entertainment', Icons.movie_filter_rounded, AppColors.pink),
  music('Music', Icons.music_note_rounded, AppColors.accent),
  productivity('Productivity', Icons.laptop_mac_rounded, AppColors.primary),
  cloud('Cloud', Icons.cloud_queue_rounded, AppColors.cyan),
  shopping('Shopping', Icons.shopping_bag_outlined, AppColors.warning),
  other('Other', Icons.category_outlined, AppColors.purple);

  final String label;
  final IconData icon;
  final Color color;

  const SubscriptionCategory(this.label, this.icon, this.color);

  static SubscriptionCategory fromString(String value) {
    return SubscriptionCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SubscriptionCategory.other,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String currencySymbol;
  final BillingCycle billingCycle;
  final DateTime nextPaymentDate;
  final SubscriptionCategory category;
  final String? notes;
  final bool isActive;
  final bool reminderEnabled;
  final int? reminderDaysBefore;
  final String? brandColorHex;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    this.currency = 'USD',
    this.currencySymbol = '\$',
    required this.billingCycle,
    required this.nextPaymentDate,
    required this.category,
    this.notes,
    this.isActive = true,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 2,
    this.brandColorHex,
  });

  /// Monthly equivalent spend
  double get monthlyEquivalent {
    switch (billingCycle) {
      case BillingCycle.weekly:
        return (price * 52) / 12;
      case BillingCycle.monthly:
        return price;
      case BillingCycle.yearly:
        return price / 12;
      case BillingCycle.custom:
        return price;
    }
  }

  /// Yearly equivalent spend
  double get yearlyEquivalent => monthlyEquivalent * 12;

  /// Days remaining until payment
  int get daysUntilPayment {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      nextPaymentDate.year,
      nextPaymentDate.month,
      nextPaymentDate.day,
    );
    return target.difference(today).inDays;
  }

  bool get isDueSoon => daysUntilPayment >= 0 && daysUntilPayment <= 7;
  bool get isDueToday => daysUntilPayment == 0;
  bool get isOverdue => daysUntilPayment < 0;

  SubscriptionModel copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    String? currencySymbol,
    BillingCycle? billingCycle,
    DateTime? nextPaymentDate,
    SubscriptionCategory? category,
    String? notes,
    bool? isActive,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    String? brandColorHex,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      billingCycle: billingCycle ?? this.billingCycle,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      brandColorHex: brandColorHex ?? this.brandColorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'billingCycle': billingCycle.name,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'category': category.name,
      'notes': notes,
      'isActive': isActive,
      'reminderEnabled': reminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
      'brandColorHex': brandColorHex,
    };
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      currencySymbol: json['currencySymbol'] as String? ?? '\$',
      billingCycle: BillingCycle.fromString(json['billingCycle'] as String? ?? 'monthly'),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      category: SubscriptionCategory.fromString(json['category'] as String? ?? 'other'),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 2,
      brandColorHex: json['brandColorHex'] as String?,
    );
  }
}
