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
    SyosetuGenreSearchData data,
  ) = _UpdateSyosetuGenreSearchData;
  const factory NovelRankEvent.updateSyosetuComprehensiveSearchData(
          SyosetuComprehensiveSearchData data) =
      _UpdateSyosetuComprehensiveSearchData;
  const factory NovelRankEvent.updateSyosetuIsekaiSearchData(
    SyosetuIsekaiSearchData data,
  ) = _UpdateSyosetuIsekaiSearchData;
  const factory NovelRankEvent.updateKakuyomuGenreSearchData(
    KakuyomuGenreSearchData data,
  ) = _UpdateKakuyomuGenreSearchData;
}
