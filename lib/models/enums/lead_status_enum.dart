enum LeadStatusEnum { hot, warm, cold, activeClient }

extension LeadStatusEnumExtension on LeadStatusEnum {
  String get label => switch (this) {
    LeadStatusEnum.hot          => 'Quente',
    LeadStatusEnum.warm         => 'Morno',
    LeadStatusEnum.cold         => 'Frio',
    LeadStatusEnum.activeClient => 'Cliente Ativo',
  };

  String get emoji => switch (this) {
    LeadStatusEnum.hot          => '🔥',
    LeadStatusEnum.warm         => '☀️',
    LeadStatusEnum.cold         => '❄️',
    LeadStatusEnum.activeClient => '⭐',
  };

  static LeadStatusEnum fromString(String? value) => switch (value) {
    'hot'           => LeadStatusEnum.hot,
    'warm'          => LeadStatusEnum.warm,
    'active_client' => LeadStatusEnum.activeClient,
    _               => LeadStatusEnum.cold,
  };
}