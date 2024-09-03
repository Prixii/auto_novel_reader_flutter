part of 'model.dart';

@freezed
class Favored with _$Favored {
  const factory Favored({
    required String id,
    required String title,
  }) = _Favored;

  factory Favored.fromJson(Map<String, dynamic> json) =>
      _$FavoredFromJson(json);

  static Favored createDefault() => const Favored(
        id: 'default',
        title: '默认收藏夹',
      );
}
