enum LeadStatus { hot, warm, cold }

extension LeadStatusExtension on LeadStatus {
  String get label => switch (this) {
    LeadStatus.hot => 'Hot',
    LeadStatus.warm => 'Warm',
    LeadStatus.cold => 'Cold',
  };

  String get emoji => switch (this) {
    LeadStatus.hot => '🔥',
    LeadStatus.warm => '☀️',
    LeadStatus.cold => '❄️',
  };
}

class LeadModel {
  final String id;
  final String name;
  final String phone;
  final String lastMessage;
  final LeadStatus status;
  final String time;

  const LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastMessage,
    required this.status,
    required this.time,
  });

  LeadModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? lastMessage,
    LeadStatus? status,
    String? time,
  }) => LeadModel(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    lastMessage: lastMessage ?? this.lastMessage,
    status: status ?? this.status,
    time: time ?? this.time,
  );
}

class InstanceModel {
  final String id;
  final String label;
  final String phone;
  final bool isConnected;

  const InstanceModel({
    required this.id,
    required this.label,
    required this.phone,
    this.isConnected = true,
  });

  String get displayName => '$label ($phone)';
}
