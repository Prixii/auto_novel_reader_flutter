part of 'model.dart';

@freezed
class PagedData with _$PagedData {
  const factory PagedData({
    @Default([]) List<WebContent> contents,
  }) = _PagedData;
}

@freezed
class WebContent with _$WebContent {
  const factory WebContent({
    required WebNovelContentType type,
    required String text,
    required double height,
    required double width,
  }) = _WebContent;
}

extension PagedDataExt on PagedData {
  PagedData appendContent(WebContent content) =>
      copyWith(contents: [...contents, content]);

  PagedData append(
    WebNovelContentType type,
    String text,
    double height,
    double width,
  ) =>
      copyWith(contents: [
        ...contents,
        WebContent(
          type: type,
          text: text,
          height: height,
          width: width,
        )
      ]);

  String get text => contents.map((e) => e.text).join('');
}

extension WebContentExt on WebContent {
  String get imgUrl => text.substring(4);
}
