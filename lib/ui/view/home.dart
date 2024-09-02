import 'package:animations/animations.dart';
import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/reader.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings.dart';
import 'package:auto_novel_reader_flutter/ui/view/web_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

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

    readWebHomeBloc(context).add(const WebHomeEvent.init());

    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (prev, state) =>
          prev.destinationIndex != state.destinationIndex,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
    );
  }
}
