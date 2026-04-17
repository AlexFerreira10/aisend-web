class InstanceModel {
  final String id;
  final String label;
  final bool isConnected;

  const InstanceModel({
    required this.id,
    required this.label,
    this.isConnected = true,
  });

  String get displayName => label;

  factory InstanceModel.fromJson(Map<String, dynamic> json) => InstanceModel(
        id: json['instanceName'] as String,
        label: json['instanceName'] as String,
        isConnected: json['isActive'] as bool? ?? true,
      );
}
