import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class FavoredList extends StatelessWidget {
  const FavoredList({
    super.key,
    required this.favoredList,
    required this.type,
    this.onSelect,
    this.editable = true,
  });

  final List<Favored> favoredList;
  final Function(Favored)? onSelect;
  final bool editable;
  final NovelType type;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        return FavoredListTile(
          favored: favoredList[index],
          onSelect: onSelect,
          type: type,
          editable: editable,
        );
      },
      itemCount: favoredList.length,
    );
  }
}

class FavoredListTile extends StatelessWidget {
  const FavoredListTile({
    super.key,
    required this.favored,
    this.onSelect,
    required this.type,
    required this.editable,
  });
  final NovelType type;

  final Favored favored;
  final Function(Favored)? onSelect;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: InkWell(
        onTap: () => onSelect?.call(favored),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  favored.title,
                ),
              ),
              if (editable && (favored.id != 'default'))
                InkWell(
                  onTap: () => _tryDelete(context),
                  child: Icon(
                    UniconsLine.trash_alt,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              const SizedBox(width: 12.0),
              if (editable)
                InkWell(
                  onTap: () => _tryRename(context),
                  child: Icon(
                    UniconsLine.edit_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _tryDelete(BuildContext widgetContext) async {
    await showDialog(
      context: widgetContext,
      builder: (context) => AlertDialog(
        title: const Text('删除收藏夹'),
        content: const Text('确定要删除吗?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () async {
                final result = await readFavoredCubit(context)
                    .deleteFavored(favoredId: favored.id, type: type);
                if (result && context.mounted) {
                  Navigator.of(context).pop(); // 关闭对话框
                }
              },
              child: const Text('确定')),
        ],
      ),
    );
  }

  _tryRename(BuildContext widgetContext) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: widgetContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重命名收藏夹'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: '收藏夹标题'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isEmpty) {
                  showWarnToast('请输入收藏夹标题');
                  return;
                } else {
                  final result = await readFavoredCubit(context).renameFavored(
                      favoredName: controller.text,
                      favoredId: favored.id,
                      type: type);
                  if (result && context.mounted) {
                    Navigator.of(context).pop(); // 关闭对话框
                  }
                }
              },
              child: const Text('重命名'),
            ),
          ],
        );
      },
    );
  }
}
