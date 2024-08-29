import 'dart:async';

import 'package:auto_novel_reader_flutter/util/channel/key_down_channel.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/home.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future.delayed(const Duration(milliseconds: 500), () {});
    return;
  }

  Future<void> _startInit() async {
    initScreenSize(context);
    prefs = await SharedPreferences.getInstance();
    localFileManager.init();
    initKeyDownChannel();
    return;
  }

  Future<void> _precacheImages() async {}

  void _leaveSplash() async {
    if (prefs.getBool('autoLogin') == true) {
      _doAutoLogin();
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeView()));
    }
  }

  _doAutoLogin() {
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    if (phone == null || password == null) {
      clearSharedPreference();
      return;
    }
  }
}

void clearSharedPreference() async {
  prefs.setString('phone', '');
  prefs.setString('password', '');
  prefs.setBool('autoLogin', false);
  prefs.setInt('helloPage', 0);
}
