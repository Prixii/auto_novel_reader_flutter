part of 'novel_rank_bloc.dart';

@freezed
class NovelRankEvent with _$NovelRankEvent {
  const factory NovelRankEvent.searchRankNovel(
    RankCategory rankCategory,
  ) = _SearchRankNovel;
  const factory NovelRankEvent.loadNextPageRankNovel(
    RankCategory rankCategory,
  ) = _LoadNextPageRankNovel;
  const factory NovelRankEvent.updateSyosetuGenreSearchData(
    SyosetuGenre genre,
    SyosetuNovelRange range,
    NovelStatus status,
  ) = _UpdateSyosetuGenreSearchData;
  const factory NovelRankEvent.updateSyosetuComprehensiveSearchData(
    SyosetuNovelRange range,
    NovelStatus status,
  ) = _UpdateSyosetuComprehensiveSearchData;
  const factory NovelRankEvent.updateSyosetuIsekaiSearchData(
    SyosetuIsekaiGenre genre,
    SyosetuNovelRange range,
    NovelStatus status,
  ) = _UpdateSyosetuIsekaiSearchData;
  const factory NovelRankEvent.updateKakuyomuGenreSearchData(
    KakuyomuGenre genre,
    NovelRange range,
  ) = _UpdateKakuyomuGenreSearchData;
}
