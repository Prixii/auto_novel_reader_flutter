import 'dart:async';

import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/channel/key_down_channel.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/home.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.wait([
        _justWait(),
        _startInit(),
        _precacheImages(),
        _initChopperClient()
      ]).then((_) => _leaveSplash());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
              child: Image.asset(
            'assets/img/character.webp',
            height: 128,
            width: 128,
          )),
        ],
      ),
    );
  }

  Future<void> _justWait() async {
    await Future.delayed(const Duration(milliseconds: 800), () {});
    return;
  }

  Future<void> _startInit() async {
    styleManager.setTheme(Theme.of(context));
    initScreenSize(context);
    localFileManager.init();
    initKeyDownChannel();
    globalBloc.add(GlobalEvent.switchNavigationDestination(
        destinationIndex: configCubit.state.helloPageIndex));
    return;
  }

  Future<void> _precacheImages() async {}

  void _leaveSplash() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
  }

  Future<void> _initChopperClient() async {
    apiClient.createChopper();
    await userCubit.activateAuth(context);
  }
}
