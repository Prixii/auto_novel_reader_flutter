import 'package:animations/animations.dart';
import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/reader.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/web_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  final List<Widget> _views = const <Widget>[
    WebHomeView(),
    ReaderView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    var reverse = true;
    if (readGlobalBloc(context).state.shouldShowNewReleaseDialog) {
      _showNewReleaseDialog(
          context, readGlobalBloc(context).state.latestReleaseData!);
    }
    readFavoredCubit(context).init();
    readDownloadCubit(context).init();
    return BlocListener<GlobalBloc, GlobalState>(
      listener: (context, state) {
        if (state.shouldShowNewReleaseDialog) {
          _showNewReleaseDialog(context, state.latestReleaseData!);
        }
      },
      child: BlocBuilder<GlobalBloc, GlobalState>(
        buildWhen: (prev, state) =>
            prev.destinationIndex != state.destinationIndex,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: styleManager.colorScheme(context).surface,
            body: Center(
              child: PageTransitionSwitcher(
                reverse: reverse,
                duration: const Duration(milliseconds: 800),
                child: _views[state.destinationIndex],
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
              ),
            ),
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (index) {
                reverse = (index < state.destinationIndex);
                readGlobalBloc(context).add(
                  GlobalEvent.switchNavigationDestination(
                      destinationIndex: index),
                );
              },
              selectedIndex: state.destinationIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(UniconsLine.house_user),
                  label: HomeViews.fromIndex(0).nameByValue,
                ),
                NavigationDestination(
                  icon: const Icon(UniconsLine.book_alt),
                  label: HomeViews.fromIndex(1).nameByValue,
                ),
                NavigationDestination(
                  icon: const Icon(UniconsLine.setting),
                  label: HomeViews.fromIndex(2).nameByValue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNewReleaseDialog(BuildContext context, ReleaseData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReleaseAlertDialog(data: data);
      },
    ).then((_) =>
        readGlobalBloc(context).add(const GlobalEvent.closeReleaseDialog()));
  }
}

class ReleaseAlertDialog extends StatelessWidget {
  const ReleaseAlertDialog({super.key, required this.data});
  final ReleaseData data;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: Text(data.body),
      actions: [
        TextButton(
          child: const Text('算了吧'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('下载新版本'),
          onPressed: () {
            Navigator.of(context).pop();
            readGlobalBloc(context).add(const GlobalEvent.closeReleaseDialog());
            launchUrl(Uri.parse(data.htmlUrl));
          },
        ),
      ],
    );
  }
}
