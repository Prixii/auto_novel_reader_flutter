import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_state.dart';
part 'comment_cubit.freezed.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit() : super(const CommentState.initial());

  void addComments(List<Comment> comments) {
    emit(state.copyWith(
      comments: comments,
    ));
  }

  void setSite(String site) {
    emit(state.copyWith(site: site));
  }

  Future<bool> hideComment(String id) async {
    final response = await apiClient.commentService.putIdHidden(id);
    if (response == null) return false;
    if (response.statusCode == 200) {
      showSucceedToast('操作成功, 刷新后生效');
      return true;
    }
    if (response.statusCode == 502) {
      showErrorToast('服务器维护中');
    }
    showErrorToast('隐藏评论失败');
    return false;
  }

  Future<bool> showComment(String id) async {
    final response = await apiClient.commentService.delIdHidden(id);
    if (response == null) return false;
    if (response.statusCode == 200) {
      showSucceedToast('操作成功, 刷新后生效');
      return true;
    }
    if (response.statusCode == 502) {
      showErrorToast('服务器维护中');
    }
    showErrorToast('显示评论失败');
    return false;
  }

  Future<bool> reply({
    required String targetId,
    required List<String> parentCommentIds,
    required String content,
  }) async {
    final response = await apiClient.commentService.postComment(
      parent: targetId,
      content: content,
      site: state.site,
    );
    if (response == null) return false;
    if (response.statusCode == 200) {
      final targetCommentIndex =
          state.comments.indexWhere((element) => element.id == targetId);
      final targetComment = state.comments[targetCommentIndex];
      var newTargetComment = targetComment.copyWith(replies: [
        ...targetComment.replies,
        Comment(
          createAt: DateTime.now().millisecondsSinceEpoch,
          content: content,
          hidden: false,
          id: 'null',
          numReplies: 0,
          replies: [],
          user: User(
            role: userCubit.state.role ?? '',
            username: userCubit.state.username ?? '',
          ),
        )
      ]);

      emit(state.copyWith(
          comments: [...state.comments]..replaceRange(
              targetCommentIndex,
              targetCommentIndex + 1,
              [newTargetComment],
            )));

      return true;
    }
    if (response.statusCode == 502) {
      showErrorToast('服务器维护中');
    }
    showErrorToast('回复评论失败');
    return false;
  }

  Future<bool> comment({
    required String content,
  }) async {
    final response = await apiClient.commentService.postComment(
      content: content,
      site: state.site,
    );
    if (response == null) return false;
    if (response.statusCode == 200) {
      showSucceedToast('评论成功');
      return true;
    }
    if (response.statusCode == 502) {
      showErrorToast('服务器维护中');
    }
    showErrorToast('评论失败');
    return false;
  }
}
