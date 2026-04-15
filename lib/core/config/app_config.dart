/// AiSend configuration center.
/// Replace [broadcastEndpoint] with your real n8n URL before deployment.
abstract final class AppConfig {
  // ─── n8n ──────────────────────────────────────────────────────────────────
  static const String broadcastEndpoint =
      'https://n8n-production-0cf8.up.railway.app/webhook/aisend-outbound';

  // ─── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 30);
}
