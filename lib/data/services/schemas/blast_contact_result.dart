class BlastContactResult {
  final String phone;
  final String name;
  final String status; // 'sent' or 'error'
  final String? error;

  const BlastContactResult({
    required this.phone,
    required this.name,
    required this.status,
    this.error,
  });

  bool get success => status == 'sent';

  factory BlastContactResult.fromJson(Map<String, dynamic> json) =>
      BlastContactResult(
        phone: json['phone'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        error: json['error'] as String?,
      );
}
