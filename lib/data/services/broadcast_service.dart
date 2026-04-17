import 'package:aisend/core/config/app_config.dart';

import 'api_client.dart';
import 'schemas/blast_response.dart';
import 'schemas/blast_contact_result.dart';

class BroadcastService {
  final ApiClient _api;
  BroadcastService(this._api);

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
}
