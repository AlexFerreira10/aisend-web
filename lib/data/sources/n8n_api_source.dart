import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../repositories/broadcast_repository.dart';

/// Concrete implementation that sends leads to the n8n webhook via HTTP POST.
///
/// Interface Contract (AiSend ↔ n8n):
///   POST [AppConfig.broadcastEndpoint]
///   Content-Type: application/json
///   Body: { phone, name, reason, instance }
class N8nApiSource implements BroadcastRepository {
  final http.Client _client;

  /// Injects an [http.Client] to facilitate unit testing.
  N8nApiSource({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<BroadcastResult> sendLead({
    required String phone,
    required String name,
    required String reason,
    required String instance,
  }) async {
    final uri = Uri.parse(AppConfig.broadcastEndpoint);

    final body = jsonEncode({
      'phone': _sanitizePhone(phone),
      'name': name,
      'reason': reason,
      'instance': instance,
    });

    try {
      // ─── Request Log ───────────────────────────────────────────────────────
      debugPrint('┌── AiSend HTTP Request');
      debugPrint('│ Method: POST');
      debugPrint('│ URL: $uri');
      debugPrint('│ Headers: {Content-Type: application/json}');
      debugPrint('│ Body: $body');
      debugPrint('└────────────────────────────────────────────────────────────────');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(AppConfig.requestTimeout);

      final success = response.statusCode >= 200 && response.statusCode < 300;

      // ─── Response Log ──────────────────────────────────────────────────────
      debugPrint('┌── AiSend HTTP Response');
      debugPrint('│ Status: ${response.statusCode}');
      debugPrint('│ Body: ${response.body}');
      debugPrint('└────────────────────────────────────────────────────────────────');

      return BroadcastResult(
        success: success,
        statusCode: response.statusCode,
        errorMessage: success ? null : _parseError(response),
      );
    } on Exception catch (e) {
      debugPrint('┌── AiSend HTTP ERROR');
      debugPrint('│ Error: $e');
      debugPrint('└────────────────────────────────────────────────────────────────');
      return BroadcastResult(
        success: false,
        statusCode: 0,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Removes non-numeric characters and ensures DDI+DDD+number.
  String _sanitizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // If it doesn't start with 55 (Brazil), add the DDI.
    if (!digits.startsWith('55') && digits.length <= 11) {
      return '55$digits';
    }
    return digits;
  }

  String _parseError(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['message'] as String? ??
          json['error'] as String? ??
          'HTTP ${response.statusCode}';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }
}
