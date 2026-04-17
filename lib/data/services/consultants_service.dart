import 'package:aisend/models/instance_model.dart';

import 'api_client.dart';
import '../../core/config/app_config.dart';

class ConsultantsService {
  final ApiClient _api;
  ConsultantsService(this._api);

  Future<List<InstanceModel>> fetchInstances() async {
    final response = await _api.get(AppConfig.instancesEndpoint);
    final list = response as List<dynamic>;
    return list
        .map((e) => InstanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
