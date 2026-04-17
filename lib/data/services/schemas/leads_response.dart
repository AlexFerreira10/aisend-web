import '../../../models/lead_model.dart';

class LeadsResponse {
  final int total;
  final int page;
  final int pageSize;
  final List<LeadModel> items;

  const LeadsResponse({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory LeadsResponse.fromJson(Map<String, dynamic> json) => LeadsResponse(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
