part of 'model.dart';

@freezed
class EpubManageData with _$EpubManageData {
  const factory EpubManageData({
    required String path,
    required String name,
    required String uid,
    @Default(0.0) double progress,
    @Default(0) int chapter,
    @Default({}) Map<String, List<String>> chapterResourceMap,
    @Default(false) bool isParsed,
    @Default(false) bool finished,
    String? filename,
    required NovelType novelType,

    // new
    // @Default([]) List<(String, NovelContentType)> parsedResults,
  }) = _EpubManageData;

  factory EpubManageData.fromJson(Map<String, dynamic> json) =>
      _$EpubManageDataFromJson(json);
}
