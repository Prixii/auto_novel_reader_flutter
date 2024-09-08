import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/favored_web_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/web_most_visited.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/wenku_latest_update.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(context),
      child: SingleChildScrollView(
        controller: ScrollController(),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FavoredWebList(),
            WebMostVisited(),
            WenkuLatestUpdate(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> refresh(BuildContext context) async {
    readWebHomeBloc(context).add(const WebHomeEvent.init());
    readWenkuHomeBloc(context).add(const WenkuHomeEvent.init());
    await Future.delayed(const Duration(seconds: 1));
  }
}
