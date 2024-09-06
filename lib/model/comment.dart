part of 'model.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int createAt,
    required String content,
    required bool hidden,
    required String id,
    required int numReplies,
    @Default([]) List<Comment> replies,
    required User user,
  }) = _Comment;
}

@freezed
class User with _$User {
  const factory User({
    required String role,
    required String username,
  }) = _User;
}
