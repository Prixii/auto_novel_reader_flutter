import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const indentSize = 12.0;

class CommentList extends StatelessWidget {
  const CommentList(
      {super.key, required this.comments, required this.parentCommentIds});

  final List<Comment> comments;
  final List<String> parentCommentIds;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      itemBuilder: (context, index) => CommentTile(
        comment: comments[index],
        parentCommentIds: parentCommentIds,
      ),
      itemCount: comments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}

class CommentTile extends StatefulWidget {
  const CommentTile(
      {super.key, required this.comment, required this.parentCommentIds});

  final Comment comment;
  final List<String> parentCommentIds;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  late bool originalHidden = false;
  var hidden = false; // 用来控制显示哪个按钮，和内容无关

  @override
  void initState() {
    super.initState();
    originalHidden = hidden = widget.comment.hidden;
  }

  @override
  Widget build(BuildContext context) {
    if (originalHidden && !isMyComment) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
          8 + indentLevel * indentSize, (indentLevel == 0) ? 8 : 4, 0, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.comment.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8.0),
              Text(
                formatTimestamp(widget.comment.createAt * 1000),
                style: styleManager.tipText(context),
              ),
              Expanded(child: Container()),
              if (isMyComment)
                if (hidden) _buildShowButton() else _buildHideButton(),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: widget.parentCommentIds.isEmpty
                ? () => _openReplyDialog(context)
                : null,
            onLongPress: () => _copyContent(),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color:
                    styleManager.colorScheme(context).surfaceContainerHighest,
              ),
              child: (originalHidden && isMyComment)
                  ? const Text('评论已隐藏')
                  : Text(widget.comment.content),
            ),
          ),
          CommentList(
            comments: widget.comment.replies,
            parentCommentIds: [...widget.parentCommentIds, widget.comment.id],
          ),
        ],
      ),
    );
  }

  _buildHideButton() {
    return InkWell(
      onTap: () async {
        final result =
            await readCommentCubit(context).hideComment(widget.comment.id);
        if (!result) return;
        setState(() {
          hidden = true;
        });
      },
      child: Text(
        '隐藏',
        style: styleManager.tipText(context)?.copyWith(
              color: styleManager.colorScheme(context).primary,
            ),
      ),
    );
  }

  _buildShowButton() {
    return InkWell(
      onTap: () async {
        final result =
            await readCommentCubit(context).showComment(widget.comment.id);
        if (!result) return;
        setState(() {
          hidden = false;
        });
      },
      child: Text(
        '显示',
        style: styleManager.tipText(context)?.copyWith(
              color: styleManager.colorScheme(context).primary,
            ),
      ),
    );
  }

  _copyContent() async {
    await Clipboard.setData(
        ClipboardData(text: originalHidden ? '' : widget.comment.content));
    showSucceedToast('已复制评论');
  }

  _openReplyDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('回复'),
          content: SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                maxLines: 20,
                onSubmitted: (content) async {
                  final result = await _reply(content);
                  if (result && context.mounted) {
                    Navigator.of(context).pop(); // 关闭对话框
                  }
                },
                autofocus: true,
                decoration: InputDecoration(
                    hintText: '回复给 ${widget.comment.user.username}'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final result = await _reply(controller.text);

                if (result && context.mounted) {
                  Navigator.of(context).pop(); // 关闭对话框
                }
              },
              child: const Text('回复'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _reply(String content) async {
    if (content.isEmpty) {
      showWarnToast('请输入内容');
      return false;
    } else {
      return await readCommentCubit(context).reply(
        targetId: widget.comment.id,
        parentCommentIds: widget.parentCommentIds,
        content: content,
      );
    }
  }

  int get indentLevel => widget.parentCommentIds.length;

  bool get isMyComment =>
      widget.comment.user.username == userCubit.state.username;
}
