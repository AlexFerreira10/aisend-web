abstract final class AppConfig {
  // ─── Backend URL & Config ──────────────────────────────────────────────────
  
  /// The base URL for the backend API. 
  /// Can be overridden via --dart-define=BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL', 
    defaultValue: 'http://56.125.23.170:5113', // Standard Production URL
  );

  /// The security API Key.
  /// Can be overridden via --dart-define=API_KEY=...
  static const String apiKey = String.fromEnvironment(
    'API_KEY', 
    defaultValue: 'aisend-test-2026',
  );

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


  static String leadEndpoint(String id) => '$baseUrl/api/leads/$id';
  static String leadMessageEndpoint(String id) => '$baseUrl/api/leads/$id/message';

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
