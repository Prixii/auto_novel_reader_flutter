part of 'model.dart';

@freezed
class ShieldConfig with _$ShieldConfig {
  const factory ShieldConfig({
    @Default(ShieldItem()) ShieldItem webShieldItem,
    @Default(ShieldItem()) ShieldItem wenkuShieldItem,
  }) = _ShieldConfig;

  factory ShieldConfig.fromJson(Map<String, dynamic> json) =>
      _$ShieldConfigFromJson(json);
}

@freezed
class ShieldItem with _$ShieldItem {
  const factory ShieldItem(
      {@Default([]) List<String> keywords,
      @Default([]) List<String> attentions}) = _ShieldItem;

  factory ShieldItem.fromJson(Map<String, dynamic> json) =>
      _$ShieldItemFromJson(json);
}
