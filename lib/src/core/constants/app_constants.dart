class AppConstants {
  static const String appName = 'SubCheck';
  static const String appTagline = 'Subscription Tracker';
  static const String appVersion = '1.0.0';

  // Navigation Labels
  static const String navHome = 'Home';
  static const String navSubscriptions = 'Subscriptions';
  static const String navInsights = 'Insights';
  static const String navSettings = 'Settings';

  // Home Screen
  static const String monthlySpendTitle = 'Monthly Spend';
  static const String monthlySpendSubtitle = 'Based on your active subscriptions';
  static const String upcomingPaymentsTitle = 'Upcoming Payments';
  static const String upcomingPaymentsSubtitle = 'Next 30 days';
  static const String seeAll = 'See all';
  static const String activeSubscriptions = 'Active';
  static const String upcomingCount = 'Upcoming';

  // Add / Edit Screen
  static const String addSubscriptionTitle = 'Add Subscription';
  static const String editSubscriptionTitle = 'Edit Subscription';
  static const String fieldName = 'Subscription Name';
  static const String fieldPrice = 'Price';
  static const String fieldCurrency = 'Currency';
  static const String fieldBillingCycle = 'Billing Cycle';
  static const String fieldNextPaymentDate = 'Next Payment Date';
  static const String fieldCategory = 'Category';
  static const String fieldNotes = 'Notes (Optional)';
  static const String fieldReminder = 'Send Payment Reminder';
  static const String btnSaveSubscription = 'Save Subscription';
  static const String btnUpdateSubscription = 'Update Subscription';

  // All Subscriptions Screen
  static const String searchSubscriptionsHint = 'Search by name or category...';
  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterCancelled = 'Cancelled';
  static const String emptySubscriptionsTitle = 'No subscriptions found';
  static const String emptySubscriptionsDesc = 'Add your recurring expenses to keep your finances in check.';

  // Insights Screen
  static const String insightsTitle = 'Insights';
  static const String insightsSubtitle = 'Spending overview & analytics';
  static const String spendingByCategory = 'Spending by Category';
  static const String monthlyVsYearly = 'Annual Projection';
  static const String highestCategory = 'Top Category';

  // Settings Screen
  static const String settingsTitle = 'Settings';
  static const String prefCurrency = 'Default Currency';
  static const String prefNotifications = 'Reminders & Notifications';
  static const String prefTheme = 'Appearance';
  static const String premiumTitle = 'SubCheck Pro';
  static const String premiumSubtitle = 'Unlimited subscriptions, sync & insights';
  static const String upgradeButton = 'Upgrade to Pro';
  static const String aboutPrivacy = 'About & Privacy';
}
