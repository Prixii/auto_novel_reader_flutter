part of 'model.dart';

@freezed
class WenkuSearchData with _$WenkuSearchData {
  const factory WenkuSearchData({
    @Default(0) int page,
    @Default(18) int pageSize,
    @Default(1) int level,
    String? query,
  }) = _WenkuSearchData;
}
