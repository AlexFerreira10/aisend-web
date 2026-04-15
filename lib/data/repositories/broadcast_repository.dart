/// Result of a broadcast attempt for a lead.
class BroadcastResult {
  final bool success;
  final int statusCode;
  final String? errorMessage;

  const BroadcastResult({
    required this.success,
    required this.statusCode,
    this.errorMessage,
  });

  bool get isNetworkError => statusCode == 0;

  @override
  String toString() =>
      'BroadcastResult(success: $success, status: $statusCode, error: $errorMessage)';
}

/// Broadcast layer contract.
/// All transport logic (HTTP, Mock, etc.) must implement this interface.
abstract class BroadcastRepository {
  /// Sends a lead to the n8n webhook.
  ///
  /// Payload sent:
  /// ```json
  /// {
  ///   "phone":    "5521972892504",
  ///   "name":     "Dr. Carlos Silva",
  ///   "reason":   "New batch of Tirzepatide...",
  ///   "instance": "Alex"
  /// }
  /// ```
  Future<BroadcastResult> sendLead({
    required String phone,
    required String name,
    required String reason,
    required String instance,
  });
}
