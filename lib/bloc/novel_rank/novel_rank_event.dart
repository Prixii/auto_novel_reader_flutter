part of 'novel_rank_bloc.dart';

@freezed
class NovelRankEvent with _$NovelRankEvent {
  const factory NovelRankEvent.searchRankNovel(
    RankCategory rankCategory,
  ) = _SearchRankNovel;
  const factory NovelRankEvent.loadNextPageRankNovel(
    RankCategory rankCategory,
  ) = _LoadNextPageRankNovel;
}
