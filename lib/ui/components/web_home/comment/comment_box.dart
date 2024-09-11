import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CommentBox extends StatefulWidget {
  const CommentBox({super.key, required this.onSucceedComment});

  final Function onSucceedComment;

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isSignIn = readUserCubit(context).isSignIn;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: styleManager.colorScheme(context).surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              enabled: isSignIn,
              controller: _controller,
              decoration: InputDecoration(
                hintText: isSignIn ? '撰写评论' : '登录后才能评论',
                hintStyle: TextStyle(
                  color: styleManager.colorScheme(context).secondaryFixedDim,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              maxLines: 1,
              onSubmitted: (_) => _submitComment,
              style: TextStyle(
                  color: styleManager
                      .colorScheme(context)
                      .onSecondaryContainer), // 输入文本颜色
            ),
          ),
        ),
        IconButton(
          icon: const Icon(UniconsLine.message),
          onPressed: isSignIn ? _submitComment : null,
        ),
      ],
    );
  }

  void _submitComment() async {
    if (_controller.text.isNotEmpty) {
      final result =
          await readCommentCubit(context).comment(content: _controller.text);
      if (result) {
        widget.onSucceedComment.call();
        setState(() {
          _controller.clear(); // 清空输入框
          FocusScope.of(context).unfocus(); // 退出键盘
        });
      }
    }
  }
}
