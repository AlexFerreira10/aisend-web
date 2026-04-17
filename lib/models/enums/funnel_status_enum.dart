enum FunnelStatusEnum { cold, warm, hot, activeClient }

extension FunnelStatusEnumExtension on FunnelStatusEnum {
  static FunnelStatusEnum fromString(String? value) => switch (value) {
    'hot' => FunnelStatusEnum.hot,
    'warm' => FunnelStatusEnum.warm,
    'active_client' => FunnelStatusEnum.activeClient,
    _ => FunnelStatusEnum.cold,
  };

  String get asString => switch (this) {
    FunnelStatusEnum.hot => 'hot',
    FunnelStatusEnum.warm => 'warm',
    FunnelStatusEnum.activeClient => 'active_client',
    FunnelStatusEnum.cold => 'cold',
  };
}