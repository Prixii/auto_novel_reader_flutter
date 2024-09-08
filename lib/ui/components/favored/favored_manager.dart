import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/favored/favored_list.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class FavoredManager extends StatelessWidget {
  const FavoredManager({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '收藏夹管理',
              textAlign: TextAlign.center,
              style: styleManager.primaryColorTitleLarge(context),
            ),
          ),
          Text(
            '网络小说',
            style: const TextStyle().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
            selector: (state) {
              return state.favoredMap[NovelType.web] ?? [];
            },
            builder: (context, state) {
              return FavoredList(
                favoredList: state,
                type: NovelType.web,
              );
            },
          ),
          BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
            selector: (state) {
              return state.favoredMap[NovelType.web] ?? [];
            },
            builder: (context, state) {
              if (state.length < 10) {
                return _buildCreator(
                  context,
                  () => _showCreateFavoredDialog(context, NovelType.web),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          Text(
            '文库小说',
            style: const TextStyle().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
            selector: (state) {
              return state.favoredMap[NovelType.wenku] ?? [];
            },
            builder: (context, state) {
              return FavoredList(
                favoredList: state,
                type: NovelType.wenku,
              );
            },
          ),
          BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
            selector: (state) {
              return state.favoredMap[NovelType.wenku] ?? [];
            },
            builder: (context, state) {
              if (state.length < 10) {
                return _buildCreator(
                  context,
                  () => _showCreateFavoredDialog(context, NovelType.wenku),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Padding _buildCreator(BuildContext context, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () => onTap.call(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: styleManager.colorScheme(context).surfaceContainerHighest,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(UniconsLine.plus,
                  color: styleManager.colorScheme(context).primary),
              const SizedBox(width: 8),
              Text('创建收藏夹',
                  style: const TextStyle().copyWith(
                      color: styleManager.colorScheme(context).primary)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateFavoredDialog(
      BuildContext context, NovelType type) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建收藏夹'),
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
                  final result = await readFavoredCubit(context)
                      .createFavored(favoredName: controller.text, type: type);
                  if (result && context.mounted) {
                    Navigator.of(context).pop(); // 关闭对话框
                  }
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }
}
