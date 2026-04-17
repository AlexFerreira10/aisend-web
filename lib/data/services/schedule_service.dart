import 'package:aisend/core/config/app_config.dart';
import 'package:aisend/models/enums/blast_status_enum.dart';
import 'api_client.dart';

class ScheduledBlastItem {
  final String id;
  final DateTime scheduledAt;
  final BlastStatus status;
  final String motivo;
  final int totalContacts;
  final int sentCount;
  final int errorCount;
  final DateTime? executedAt;
  final String? consultantName;
  final String? instance;

  const ScheduledBlastItem({
    required this.id,
    required this.scheduledAt,
    required this.status,
    required this.motivo,
    required this.totalContacts,
    required this.sentCount,
    required this.errorCount,
    this.executedAt,
    this.consultantName,
    this.instance,
  });

  factory ScheduledBlastItem.fromJson(Map<String, dynamic> j) =>
      ScheduledBlastItem(
        id: j['id'] as String,
        scheduledAt: DateTime.parse(j['scheduledAt'] as String),
        status: BlastStatus.fromString(j['status'] as String? ?? ''),
        motivo: j['motivo'] as String? ?? '',
        totalContacts: j['totalContacts'] as int? ?? 0,
        sentCount: j['sentCount'] as int? ?? 0,
        errorCount: j['errorCount'] as int? ?? 0,
        executedAt: j['executedAt'] != null
            ? DateTime.parse(j['executedAt'] as String)
            : null,
        consultantName: j['consultantName'] as String?,
        instance: j['instance'] as String?,
      );
}

class ScheduleService {
  final ApiClient _api;
  ScheduleService(this._api);

  Future<List<ScheduledBlastItem>> fetchScheduled() async {
    final response = await _api.get(AppConfig.scheduledEndpoint);
    final items = (response as Map<String, dynamic>)['items'] as List<dynamic>;
    return items
        .map((e) => ScheduledBlastItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    await _api.post(AppConfig.scheduleEndpoint, body: data);
  }

  Future<void> cancel(String id) async {
    await _api.delete(AppConfig.scheduledCancelEndpoint(id));
  }
}
