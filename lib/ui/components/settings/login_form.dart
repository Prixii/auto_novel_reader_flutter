import 'package:auto_novel_reader_flutter/ui/components/settings/auth_tab.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/custom_text_field.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailOrUsernameController, _passwordController;
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _emailOrUsernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField('用户名/邮箱', _emailOrUsernameController),
        space,
        buildTextField('密码', _passwordController, obscureText: true),
        space,
        Row(
          children: [
            Checkbox(
              value: isRememberMeChecked,
              onChanged: (value) => {
                if (value != null) setState(() => isRememberMeChecked = value)
              },
              visualDensity: VisualDensity.compact,
            ),
            const Text(
              '记住我',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            Expanded(child: Container()),
          ],
        ),
        space,
        buildRoundButton(() => _doLogin(context)),
      ],
    );
  }

  void _doLogin(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formFinished()) {
      readUserCubit(context).signIn(
        context,
        _emailOrUsernameController.text,
        _passwordController.text,
        autoLogin: isRememberMeChecked,
      );
    } else {
      _showToast(context);
    }
  }

  bool _formFinished() {
    return (_emailOrUsernameController.text != '') &&
        (_passwordController.text != '');
  }

  void _showToast(BuildContext context) {
    Fluttertoast.showToast(msg: '请填写完整信息');
  }
}
