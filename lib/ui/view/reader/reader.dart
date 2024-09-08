import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/favored.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/history.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/local_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReaderView extends StatefulWidget {
  const ReaderView({super.key});

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  var isModalVisible = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: styleManager.colorScheme(context).shadow,
          backgroundColor: styleManager.colorScheme(context).secondaryContainer,
          title: _buildTabBar(),
        ),
        body: BlocListener<GlobalBloc, GlobalState>(
          listener: (context, state) {
            if (isModalVisible && state.progressTypeValue == null) {
              Navigator.of(context).pop();
              isModalVisible = false;
              return;
            }
            if (state.progressTypeValue != ProgressType.parsingEpub.value) {
              return;
            }
            isModalVisible = true;
            _showProgressDialog(context);
          },
          listenWhen: (previous, current) {
            return previous.progressTypeValue != current.progressTypeValue;
          },
          child: const TabBarView(
            children: [
              FavoredView(),
              HistoryView(),
              LocalBookView(),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showProgressDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
            return AlertDialog(
                title: const Text('正在解析 epub'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: state.progressValue / 100,
                    ),
                    Text('${state.progressMessage} ${state.progressValue}%'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                    child: const Text('终止'),
                  ),
                ]);
          });
        });
  }

  TabBar _buildTabBar() {
    return const TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: [
        Tab(text: '收藏'),
        Tab(text: '历史'),
        Tab(text: '本地'),
      ],
    );
  }
}
