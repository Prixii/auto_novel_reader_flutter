part of 'model.dart';

@freezed
class ConfigData extends HiveObject with _$ConfigData {
  ConfigData._();
  @HiveType(typeId: 2)
  factory ConfigData({
    @HiveField(1) @Default(false) bool? slideShift,
  }) = _ConfigData;

  factory ConfigData.fromJson(Map<String, dynamic> json) =>
      _$ConfigDataFromJson(json);
}
