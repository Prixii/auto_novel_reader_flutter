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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24), // 圆角
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '撰写评论',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixedDim,
                ), // 提示文本颜色
                border: InputBorder.none, // 去掉默认边框
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20), // 内边距
              ),
              maxLines: 1,
              onSubmitted: (_) => _submitComment,
              style: TextStyle(
                  color:
                      styleManager.colorScheme.onSecondaryContainer), // 输入文本颜色
            ),
          ),
        ),
        IconButton(
          icon: const Icon(UniconsLine.message),
          onPressed: _submitComment,
        ),
      ],
    );
  }
}
