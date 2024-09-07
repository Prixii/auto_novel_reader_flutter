import 'package:auto_novel_reader_flutter/ui/components/settings/auth_tab.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/custom_text_field.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailOrUsernameController, _passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isRememberMeChecked = true;
  var requesting = false;

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
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField(
            '用户名/邮箱',
            _emailOrUsernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名/邮箱';
              }
              return null;
            },
          ),
          space,
          buildTextField('密码', _passwordController, obscureText: true,
              validator: (value) {
            if (value == null || value.length < 8) {
              return '密码至少为 8 个字符';
            }
            return null;
          }, inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r"\s")),
          ]),
          space,
          // _buildRememberCheckBok(),
          // space,
          buildRoundButton(() => _doSignIn(context)),
        ],
      ),
    );
  }

  // Row _buildRememberCheckBok() {
  //   return Row(
  //     children: [
  //       Checkbox(
  //         value: isRememberMeChecked,
  //         onChanged: (value) =>
  //             {if (value != null) setState(() => isRememberMeChecked = value)},
  //         visualDensity: VisualDensity.compact,
  //       ),
  //       const Text(
  //         '记住我',
  //         style: TextStyle(color: Colors.black87, fontSize: 14),
  //       ),
  //       Expanded(child: Container()),
  //     ],
  //   );
  // }

  void _doSignIn(BuildContext context) async {
    if (requesting) return;
    if (_formKey.currentState!.validate()) {
      requesting = true;
      final isSignInSucceed = await readUserCubit(context).signIn(
        _emailOrUsernameController.text,
        _passwordController.text,
        autoSignIn: isRememberMeChecked,
      );
      requesting = false;
      if (isSignInSucceed && context.mounted) {
        Navigator.pop(context);
      }
    } else {
      _showToast(context);
    }
  }

  void _showToast(BuildContext context) {
    Fluttertoast.showToast(msg: '请填写完整信息');
  }
}
