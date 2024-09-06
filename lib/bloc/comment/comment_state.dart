part of 'comment_cubit.dart';

@freezed
class CommentState with _$CommentState {
  const factory CommentState.initial({
    @Default([]) List<Comment> comments,
    @Default(0) int maxPage,
    @Default(0) int currentPage,
    @Default('') String site,
  }) = _Initial;
}
