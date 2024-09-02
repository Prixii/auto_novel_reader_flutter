part of 'model.dart';

@freezed
class ChapterDto with _$ChapterDto {
  const factory ChapterDto({
    List<String>? youdaoParagraphs,
    List<String>? originalParagraphs,
    List<String>? baiduParagraphs,
    List<String>? gptParagraphs,
    List<String>? sakuraParagraphs,
    String? nextId,
    String? previousId,
    String? titleJp,
    String? titleZh,
  }) = _ChapterDto;
}
