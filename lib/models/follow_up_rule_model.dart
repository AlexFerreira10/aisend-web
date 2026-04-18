class FollowUpRuleModel {
  final String id;
  final String consultantId;
  final String name;
  final bool isEnabled;
  final int daysWithoutResponse;
  final List<String> targetClassifications;
  final String messageMode;
  final String? fixedMessage;
  final int maxAttempts;
  final int scheduleHour;

  const FollowUpRuleModel({
    required this.id,
    required this.consultantId,
    required this.name,
    this.isEnabled = true,
    this.daysWithoutResponse = 7,
    this.targetClassifications = const ['warm', 'hot'],
    this.messageMode = 'ai',
    this.fixedMessage,
    this.maxAttempts = 3,
    this.scheduleHour = 9,
  });

  factory FollowUpRuleModel.fromJson(Map<String, dynamic> json) =>
      FollowUpRuleModel(
        id: json['id'] as String,
        consultantId: json['consultantId'] as String,
        name: json['name'] as String? ?? 'Nova regra',
        isEnabled: json['isEnabled'] as bool? ?? true,
        daysWithoutResponse: json['daysWithoutResponse'] as int? ?? 7,
        targetClassifications:
            (json['targetClassifications'] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList() ??
                ['warm', 'hot'],
        messageMode: json['messageMode'] as String? ?? 'ai',
        fixedMessage: json['fixedMessage'] as String?,
        maxAttempts: json['maxAttempts'] as int? ?? 3,
        scheduleHour: json['scheduleHour'] as int? ?? 9,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'isEnabled': isEnabled,
        'daysWithoutResponse': daysWithoutResponse,
        'targetClassifications': targetClassifications,
        'messageMode': messageMode,
        'fixedMessage': fixedMessage,
        'maxAttempts': maxAttempts,
        'scheduleHour': scheduleHour,
      };

  FollowUpRuleModel copyWith({
    String? name,
    bool? isEnabled,
    int? daysWithoutResponse,
    List<String>? targetClassifications,
    String? messageMode,
    String? fixedMessage,
    int? maxAttempts,
    int? scheduleHour,
  }) =>
      FollowUpRuleModel(
        id: id,
        consultantId: consultantId,
        name: name ?? this.name,
        isEnabled: isEnabled ?? this.isEnabled,
        daysWithoutResponse: daysWithoutResponse ?? this.daysWithoutResponse,
        targetClassifications:
            targetClassifications ?? this.targetClassifications,
        messageMode: messageMode ?? this.messageMode,
        fixedMessage: fixedMessage ?? this.fixedMessage,
        maxAttempts: maxAttempts ?? this.maxAttempts,
        scheduleHour: scheduleHour ?? this.scheduleHour,
      );

  FollowUpRuleModel withEnabled(bool value) => copyWith(isEnabled: value);
}

FollowUpRuleModel emptyRule(String consultantId) => FollowUpRuleModel(
      id: '',
      consultantId: consultantId,
      name: 'Nova regra',
    );
