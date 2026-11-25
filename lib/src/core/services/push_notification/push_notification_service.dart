class PushNotificationService {
  Future<void> initialize() async {
    // Push notification bootstrap (Firebase / Local Notifications)
  }

  Future<void> schedulePaymentReminder({
    required String subscriptionId,
    required String title,
    required DateTime paymentDate,
  }) async {
    // Schedule local notification reminder
  }

  Future<void> cancelReminder(String subscriptionId) async {
    // Cancel scheduled reminder
  }
}
