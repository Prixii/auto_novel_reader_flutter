part of 'model.dart';

@freezed
class EpubManageData extends HiveObject with _$EpubManageData {
  EpubManageData._();

  @HiveType(typeId: 1)
  factory EpubManageData({
    @HiveField(1) required String? path,
    @HiveField(2) required String? name,
    @HiveField(3) required String? uid,
    @HiveField(4) @Default(0.0) double? progress,
    @HiveField(5) @Default(0) int? chapter,
    @HiveField(6) @Default({}) Map<String, List<String>>? chapterResourceMap,
    @HiveField(7) @Default(false) bool? isParsed,
    @HiveField(8) @Default(false) bool? finished,
  }) = _EpubManageData;

  factory EpubManageData.fromJson(Map<String, dynamic> json) =>
      _$EpubManageDataFromJson(json);
}
