abstract final class AppConfig {
  // ─── Backend URL ──────────────────────────────────────────────────────────
  static const String _prodUrl = 'http://56.125.23.170:5113';

  static String get baseUrl => _prodUrl;

  // ─── Endpoints ───────────────────────────────────────────────────────────
  static String get healthEndpoint      => '$baseUrl/health';
  static String get instancesEndpoint   => '$baseUrl/api/consultants/instances';
  static String get blastEndpoint          => '$baseUrl/api/outbound/blast';
  static String get previewEndpoint        => '$baseUrl/api/outbound/preview';
  static String get parseContactsEndpoint  => '$baseUrl/api/outbound/parse-contacts';
  static String get leadsEndpoint       => '$baseUrl/api/leads';
  static String get broadcastsEndpoint   => '$baseUrl/api/outbound/broadcasts';
  static String get scheduleEndpoint     => '$baseUrl/api/outbound/schedule';
  static String get scheduledEndpoint    => '$baseUrl/api/outbound/scheduled';
  static String scheduledCancelEndpoint(String id) =>
      '$baseUrl/api/outbound/scheduled/$id';

  static String captureUrl(String instance) =>
      '$baseUrl/api/capture/$instance';

  static String messagesEndpoint(String phone) =>
      '$baseUrl/api/leads/$phone/messages';

  static String waitingEndpoint(String phone) =>
      '$baseUrl/api/leads/$phone/waiting';

  static String followUpRulesEndpoint(String consultantId) =>
      '$baseUrl/api/followuprules/$consultantId';

  static String followUpRuleEndpoint(String id) =>
      '$baseUrl/api/followuprules/$id';

  static String followUpRuleToggleEndpoint(String id) =>
      '$baseUrl/api/followuprules/$id/toggle';

  // ─── Config ───────────────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 30);
}
