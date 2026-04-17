import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  // ─── Backend URL ──────────────────────────────────────────────────────────
  // debug mode  → localhost (flutter run)
  // release mode → EC2      (flutter build web / flutter run --release)
  static const String _localUrl = 'http://localhost:5113';
  static const String _prodUrl  = 'http://56.125.23.170:5113';

  static String get baseUrl => kReleaseMode ? _prodUrl : _localUrl;

  // ─── Endpoints ───────────────────────────────────────────────────────────
  static String get healthEndpoint      => '$baseUrl/health';
  static String get instancesEndpoint   => '$baseUrl/api/consultants/instances';
  static String get blastEndpoint       => '$baseUrl/api/outbound/blast';
  static String get previewEndpoint     => '$baseUrl/api/outbound/preview';
  static String get leadsEndpoint       => '$baseUrl/api/leads';
  static String get broadcastsEndpoint  => '$baseUrl/api/outbound/broadcasts';

  static String messagesEndpoint(String phone) =>
      '$baseUrl/api/leads/$phone/messages';

  static String waitingEndpoint(String phone) =>
      '$baseUrl/api/leads/$phone/waiting';

  // ─── Config ───────────────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 30);
}
