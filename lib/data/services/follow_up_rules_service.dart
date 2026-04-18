import 'package:aisend/core/config/app_config.dart';
import 'package:aisend/models/follow_up_rule_model.dart';

import 'api_client.dart';

class FollowUpRulesService {
  final ApiClient _api;
  FollowUpRulesService(this._api);

  Future<List<FollowUpRuleModel>> fetchRules(String consultantId) async {
    final response = await _api.get(AppConfig.followUpRulesEndpoint(consultantId));
    final list = response as List<dynamic>;
    return list
        .map((e) => FollowUpRuleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FollowUpRuleModel> createRule(
      String consultantId, FollowUpRuleModel rule) async {
    final response = await _api.post(
      AppConfig.followUpRulesEndpoint(consultantId),
      body: rule.toJson(),
    );
    return FollowUpRuleModel.fromJson(response as Map<String, dynamic>);
  }

  Future<FollowUpRuleModel> updateRule(FollowUpRuleModel rule) async {
    final response = await _api.put(
      AppConfig.followUpRuleEndpoint(rule.id),
      body: rule.toJson(),
    );
    return FollowUpRuleModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> toggleRule(String id) async {
    await _api.patch(AppConfig.followUpRuleToggleEndpoint(id), body: {});
  }

  Future<void> deleteRule(String id) async {
    await _api.delete(AppConfig.followUpRuleEndpoint(id));
  }
}
