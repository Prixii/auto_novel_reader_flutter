import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/favored_web_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/web_most_visited.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/wenku_latest_update.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/nav_title.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(context),
      child: SingleChildScrollView(
        controller: ScrollController(),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFavoredNavTitle(),
            BlocSelector<WebHomeBloc, WebHomeState, LoadingStatus?>(
              selector: (state) {
                return state.loadingStatusMap[RequestLabel.loadWebFavored];
              },
              builder: (context, loadingStatus) {
                return TimeoutInfoContainer(
                  status: loadingStatus,
                  child: const FavoredWebList(),
                  onRetry: () => loadWebFavored(context),
                );
              },
            ),
            _buildWebNavTitle(),
            BlocSelector<WebHomeBloc, WebHomeState, LoadingStatus?>(
              selector: (state) {
                return state.loadingStatusMap[RequestLabel.loadWebMostVisited];
              },
              builder: (context, loadingStatus) {
                return TimeoutInfoContainer(
                  status: loadingStatus,
                  child: const WebMostVisited(),
                  onRetry: () => loadWebMostVisited(context),
                );
              },
            ),
            _buildWenkuNavTitle(),
            BlocSelector<WenkuHomeBloc, WenkuHomeState, LoadingStatus?>(
              selector: (state) {
                return state
                    .loadingStatusMap[RequestLabel.loadWenkuLatestUpdated];
              },
              builder: (context, loadingStatus) {
                return TimeoutInfoContainer(
                  status: loadingStatus,
                  child: const WenkuLatestUpdate(),
                  onRetry: () => loadWenkuLatestUpdate(context),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoredNavTitle() {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) {
        return state.token != null;
      },
      builder: (context, isSignIn) {
        return NavTitle(
            title: '我的收藏${isSignIn ? '' : '(请先登录)'}',
            prefix: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  UniconsLine.star,
                  size: 22,
                ),
                SizedBox(height: 3),
              ],
            ),
            jumpTo: () {});
      },
    );
  }

  Widget _buildWebNavTitle() => NavTitle(
      title: '网络小说-最多点击',
      prefix: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UniconsLine.globe,
            size: 22,
          ),
          SizedBox(height: 3),
        ],
      ),
      jumpTo: () => {});

  Widget _buildWenkuNavTitle() => NavTitle(
      title: '文库小说-最近更新',
      prefix: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UniconsLine.books,
            size: 22,
          ),
          SizedBox(height: 3),
        ],
      ),
      jumpTo: () => {});

  Future<void> refresh(BuildContext context) async {
    await Future.wait([
      loadWebFavored(context),
      loadWebMostVisited(context),
      loadWenkuLatestUpdate(context),
    ]);
  }

  void _init() {
    final webMostVisited = readWebHomeBloc(context).state.webMostVisited;
    if (webMostVisited == null || webMostVisited.isEmpty) {
      loadWebMostVisited(context);
    }
    final wenkuLatestUpdate =
        readWenkuHomeBloc(context).state.wenkuLatestUpdate;
    if (wenkuLatestUpdate == null || wenkuLatestUpdate.isEmpty) {
      loadWenkuLatestUpdate(context);
    }
    if (readUserCubit(context).state.token == null) return;
    final webFavored = readWebHomeBloc(context).state.favoredWebMap;
    if (webFavored.isEmpty) {
      loadWebFavored(context);
    }
  }

  Future<void> loadWebFavored(BuildContext context) async {
    final bloc = readWebHomeBloc(context);
    bloc.add(const WebHomeEvent.setLoadingState({
      RequestLabel.loadWebFavored: LoadingStatus.loading,
    }));
    try {
      final (webNovelOutlineList, _) = await loadFavoredWebOutline();

      bloc.add(WebHomeEvent.setWebFavored(webNovelOutlineList));
      bloc.add(const WebHomeEvent.setLoadingState({
        RequestLabel.loadWebFavored: null,
      }));
    } catch (e) {
      bloc.add(WebHomeEvent.setLoadingState({
        RequestLabel.loadWebFavored: (e is ServerException)
            ? LoadingStatus.serverError
            : LoadingStatus.failed,
      }));
    }
  }

  Future<void> loadWebMostVisited(BuildContext context) async {
    final bloc = readWebHomeBloc(context);
    bloc.add(const WebHomeEvent.setLoadingState({
      RequestLabel.loadWebMostVisited: LoadingStatus.loading,
    }));
    try {
      final (webNovelOutlineList, _) = await loadPagedWebOutline(
        provider: NovelProvider.values.map((e) => e.name).join(','),
      );
      bloc.add(WebHomeEvent.setWebMostVisited(webNovelOutlineList));
      bloc.add(const WebHomeEvent.setLoadingState({
        RequestLabel.loadWebMostVisited: null,
      }));
    } catch (e) {
      bloc.add(WebHomeEvent.setLoadingState({
        RequestLabel.loadWebMostVisited: (e is ServerException)
            ? LoadingStatus.serverError
            : LoadingStatus.failed,
      }));
    }
  }

  Future<void> loadWenkuLatestUpdate(BuildContext context) async {
    final bloc = readWenkuHomeBloc(context);
    bloc.add(const WenkuHomeEvent.setLoadingState({
      RequestLabel.loadWenkuLatestUpdated: LoadingStatus.loading,
    }));
    try {
      final (wenkuNovelOutlineList, _) = await loadPagedWenkuOutline(level: 1);
      bloc.add(WenkuHomeEvent.setWenkuNovelOutlines(wenkuNovelOutlineList));
      bloc.add(const WenkuHomeEvent.setLoadingState({
        RequestLabel.loadWenkuLatestUpdated: null,
      }));
    } catch (e) {
      bloc.add(WenkuHomeEvent.setLoadingState({
        RequestLabel.loadWenkuLatestUpdated: (e is ServerException)
            ? LoadingStatus.serverError
            : LoadingStatus.failed,
      }));
    }
  }
}
