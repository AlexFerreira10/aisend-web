import 'package:aisend/core/config/app_config.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/models/message_model.dart';

import 'api_client.dart';
import 'schemas/leads_response.dart';

class LeadsService {
  final ApiClient _api;
  LeadsService(this._api);

  Future<LeadsResponse> fetchLeads({
    String? instanceName,
    String? classification,
    bool? waitingHuman,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'instanceName': ?instanceName,
      'classification': ?classification,
      'waitingHuman': ?waitingHuman?.toString(),
      'search': ?search,
    };
    final uri =
        Uri.parse(AppConfig.leadsEndpoint).replace(queryParameters: params);
    final response = await _api.getUri(uri);
    if (response is List) {
      return LeadsResponse(
        total: response.length,
        page: page,
        pageSize: pageSize,
        items: response
            .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (response is Map<String, dynamic>) {
      return LeadsResponse.fromJson(response);
    }
    throw Exception('Resposta inesperada do servidor');
  }

  Future<List<MessageModel>> fetchMessages(String phone) async {
    final response = await _api.get(AppConfig.messagesEndpoint(phone));
    final list = response as List<dynamic>;
    return list
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setWaitingHuman(String phone, {required bool waiting}) async {
    await _api.patch(
      AppConfig.waitingEndpoint(phone),
      body: {'waitingHuman': waiting},
    );
  }
}
