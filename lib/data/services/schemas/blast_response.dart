import 'blast_contact_result.dart';

class BlastResponse {
  final int total;
  final int sent;
  final int errors;
  final List<BlastContactResult> results;

  const BlastResponse({
    required this.total,
    required this.sent,
    required this.errors,
    required this.results,
  });

  factory BlastResponse.fromJson(Map<String, dynamic> json) => BlastResponse(
        total: json['total'] as int? ?? 0,
        sent: json['sent'] as int? ?? 0,
        errors: json['errors'] as int? ?? 0,
        results: (json['results'] as List<dynamic>? ?? [])
            .map((e) => BlastContactResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
