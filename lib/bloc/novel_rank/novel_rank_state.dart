part of 'novel_rank_bloc.dart';

@freezed
class NovelRankState with _$NovelRankState {
  const factory NovelRankState.initial({
    @Default({}) Map<RankCategory, LoadingStatus?> loadingStatus,
    @Default({}) Map<RankCategory, List<WebNovelOutline>> novels,
    @Default({}) Map<RankCategory, int> maxPage,
    @Default({}) Map<RankCategory, int> currentPage,
    //
    @Default(SyosetuGenreSearchData())
    SyosetuGenreSearchData syosetuGenreSearchData,
    @Default(SyosetuComprehensiveSearchData())
    SyosetuComprehensiveSearchData syosetuComprehensiveSearchData,
    @Default(SyosetuIsekaiSearchData())
    SyosetuIsekaiSearchData syosetuIsekaiSearchData,
    @Default(KakuyomuGenreSearchData())
    KakuyomuGenreSearchData kakuyomuGenreSearchData,
  }) = _Initial;
}

@freezed
class SyosetuGenreSearchData with _$SyosetuGenreSearchData {
  const SyosetuGenreSearchData._();
  const factory SyosetuGenreSearchData({
    @Default(SyosetuGenre.romanceFantasy) SyosetuGenre genre,
    @Default(SyosetuNovelRange.total) SyosetuNovelRange range,
    @Default(NovelStatus.all) NovelStatus status,
  }) = _SyosetuGenreSearchData;

  Map<String, String> get query => {
        'type': '流派',
        'genre': genre.zhName,
        'range': range.zhName,
        'status': status.zhName,
      };
}

@freezed
class SyosetuComprehensiveSearchData with _$SyosetuComprehensiveSearchData {
  const SyosetuComprehensiveSearchData._();
  const factory SyosetuComprehensiveSearchData({
    @Default(SyosetuNovelRange.total) SyosetuNovelRange range,
    @Default(NovelStatus.all) NovelStatus status,
  }) = _SyosetuComprehensiveSearchData;

  Map<String, String> get query => {
        'type': '综合',
        'range': range.zhName,
        'status': status.zhName,
      };
}

@freezed
class SyosetuIsekaiSearchData with _$SyosetuIsekaiSearchData {
  const SyosetuIsekaiSearchData._();
  const factory SyosetuIsekaiSearchData({
    @Default(SyosetuIsekaiGenre.romance) SyosetuIsekaiGenre genre,
    @Default(SyosetuNovelRange.total) SyosetuNovelRange range,
    @Default(NovelStatus.all) NovelStatus status,
  }) = _SyosetuIsekaiSearchData;

  Map<String, String> get query => {
        'type': '异世界转生/转移',
        'genre': genre.zhName,
        'range': range.zhName,
        'status': status.zhName,
      };
}

@freezed
class KakuyomuGenreSearchData with _$KakuyomuGenreSearchData {
  const KakuyomuGenreSearchData._();
  const factory KakuyomuGenreSearchData({
    @Default(KakuyomuGenre.comprehensive) KakuyomuGenre genre,
    @Default(NovelRange.total) NovelRange range,
  }) = _KakuyomuGenreSearchData;

  Map<String, String> get query => {
        'genre': genre.zhName,
        'range': range.zhName,
      };
}
