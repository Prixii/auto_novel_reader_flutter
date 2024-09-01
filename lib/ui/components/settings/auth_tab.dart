import 'package:auto_novel_reader_flutter/ui/components/settings/login_form.dart';
import 'package:auto_novel_reader_flutter/ui/components/settings/register_form.dart';
import 'package:auto_novel_reader_flutter/ui/components/settings/reset_password_form.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AuthTab extends StatelessWidget {
  const AuthTab({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [Tab(text: '登录'), Tab(text: '注册'), Tab(text: '重置')];
    return DefaultTabController(
      length: tabs.length,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: TabBar(
                  dividerColor: Colors.transparent,
                  tabs: tabs,
                ),
              ),
              Expanded(flex: 2, child: Container())
            ],
          ),
        ),
        const Expanded(
          child: TabBarView(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(36.0),
                  child: LoginForm(),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(36.0),
                  child: RegisterForm(),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(36.0),
                  child: ResetPasswordForm(),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

const space = SizedBox(height: 30.0);
const textStyle = TextStyle(
  fontSize: 16.0,
  height: 1,
  textBaseline: TextBaseline.ideographic,
);

Widget buildRoundButton(void Function() onPressed) {
  return IconButton.filled(
    disabledColor: Colors.grey,
    onPressed: onPressed,
    iconSize: 32,
    padding: const EdgeInsets.all(16),
    style: ButtonStyle(
      shape: WidgetStateProperty.all(
        const CircleBorder(),
      ),
    ),
    icon: const Icon(
      UniconsLine.arrow_right,
    ),
  );
}
