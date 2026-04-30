import 'enums/lead_status_enum.dart';
import 'enums/funnel_status_enum.dart';

class LeadModel {
  final String id;
  final String name;
  final String phone;
  final String? consultantId;
  final FunnelStatusEnum funnelStatus;
  final LeadStatusEnum aiClassification;
  final bool waitingHuman;
  final String? specialty;
  final String? registration;
  final String lastMessage;
  final DateTime? lastInteractionAt;
  final DateTime createdAt;

  const LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    this.specialty,
    this.registration,
    this.consultantId,
    this.funnelStatus = FunnelStatusEnum.cold,
    this.aiClassification = LeadStatusEnum.cold,
    this.waitingHuman = false,
    this.lastMessage = '',
    this.lastInteractionAt,
    required this.createdAt,
  });


  LeadStatusEnum get status => aiClassification;

  String get time {
    if (lastInteractionAt == null) return 'Nunca';
    final diff = DateTime.now().toUtc().difference(lastInteractionAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Sem nome',
        phone: json['phone'] as String,
        specialty: (json['specialty'] == 'null') ? null : json['specialty'] as String?,
        registration: json['registration'] as String?,
        consultantId: json['consultantId'] as String?,
        funnelStatus: FunnelStatusEnumExtension.fromString(json['funnelStatus'] as String?),
        aiClassification: LeadStatusEnumExtension.fromString(json['aiClassification'] as String?),
        waitingHuman: json['waitingHuman'] as bool? ?? false,
        lastMessage: json['lastMessage'] as String? ?? '',
        lastInteractionAt: json['lastInteractionAt'] != null
            ? DateTime.parse(json['lastInteractionAt'] as String)
            : null,
        createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );

  LeadModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? specialty,
    String? registration,
    String? consultantId,
    FunnelStatusEnum? funnelStatus,
    LeadStatusEnum? aiClassification,
    bool? waitingHuman,
    String? lastMessage,
    DateTime? lastInteractionAt,
    DateTime? createdAt,
  }) =>
      LeadModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        specialty: specialty ?? this.specialty,
        registration: registration ?? this.registration,
        consultantId: consultantId ?? this.consultantId,
        funnelStatus: funnelStatus ?? this.funnelStatus,
        aiClassification: aiClassification ?? this.aiClassification,
        waitingHuman: waitingHuman ?? this.waitingHuman,
        lastMessage: lastMessage ?? this.lastMessage,
        lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
        createdAt: createdAt ?? this.createdAt,
      );
}
