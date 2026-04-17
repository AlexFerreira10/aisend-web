enum LeadStatusEnum { hot, warm, cold }

extension LeadStatusEnumExtension on LeadStatusEnum {
  String get label => switch (this) {
    LeadStatusEnum.hot => 'Quente',
    LeadStatusEnum.warm => 'Morno',
    LeadStatusEnum.cold => 'Frio',
  };

  String get emoji => switch (this) {
    LeadStatusEnum.hot => '🔥',
    LeadStatusEnum.warm => '☀️',
    LeadStatusEnum.cold => '❄️',
  };

  static LeadStatusEnum fromString(String? value) => switch (value) {
    'hot' => LeadStatusEnum.hot,
    'warm' => LeadStatusEnum.warm,
    _ => LeadStatusEnum.cold,
  };
}