import 'package:aisend/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'schemas/blast_response.dart';
import 'schemas/blast_contact_result.dart';

class ParsedContact {
  final String name;
  final String phone;
  final String? specialty;
  final String? city;

  const ParsedContact({
    required this.name,
    required this.phone,
    this.specialty,
    this.city,
  });

  factory ParsedContact.fromJson(Map<String, dynamic> j) => ParsedContact(
        name: j['name'] as String? ?? 'Sem nome',
        phone: j['phone'] as String,
        specialty: j['specialty'] as String?,
        city: j['city'] as String?,
      );
}

class ParseContactsResult {
  final List<ParsedContact> contacts;
  final List<String> warnings;
  final int total;

  const ParseContactsResult({
    required this.contacts,
    required this.warnings,
    required this.total,
  });
}

class BroadcastService {
  final ApiClient _api;
  final Dio _dio = Dio();
  BroadcastService(this._api);

  Future<ParseContactsResult> parseContacts(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      AppConfig.parseContactsEndpoint,
      data: formData,
      options: Options(
        headers: {
          'X-Api-Key': AppConfig.apiKey,
        },
      ),
    );
    final data = response.data as Map<String, dynamic>;
    // ApiResponse envelope — unwrap manually since we use Dio directly
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao processar arquivo');
    }
    final payload = data['data'] as Map<String, dynamic>;
    final contacts = (payload['contacts'] as List)
        .map((e) => ParsedContact.fromJson(e as Map<String, dynamic>))
        .toList();
    final warnings = (payload['warnings'] as List).cast<String>();
    return ParseContactsResult(
      contacts: contacts,
      warnings: warnings,
      total: payload['total'] as int,
    );
  }

  Future<BlastResponse> sendBlast(Map<String, dynamic> data) async {
    final response = await _api.post(AppConfig.blastEndpoint, body: data);
    return BlastResponse.fromJson(response);
  }

  Future<List<BlastContactResult>> getBlastResults(String blastId) async {
    final response = await _api.get('${AppConfig.blastEndpoint}/$blastId/results');
    final list = response as List<dynamic>;
    return list
        .map((e) => BlastContactResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> preview(Map<String, dynamic> data) async {
    final response = await _api.post(AppConfig.previewEndpoint, body: data);
    final parts = (response as Map<String, dynamic>)['parts'] as List<dynamic>;
    return parts.cast<String>();
  }
}
