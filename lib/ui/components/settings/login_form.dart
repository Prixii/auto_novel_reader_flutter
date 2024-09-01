import 'package:auto_novel_reader_flutter/ui/components/settings/auth_tab.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _phoneController, _passwordController;
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField('用户名/邮箱', _phoneController, inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ]),
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
            Text(
              '记住我',
              style: const TextStyle(color: Colors.black87, fontSize: 14),
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
      // TODO
    } else {
      _showToast(context);
    }
  }

  bool _formFinished() {
    return (_phoneController.text != '') && (_passwordController.text != '');
  }

  void _showToast(BuildContext context) {
    Fluttertoast.showToast(msg: '请填写完整信息');
  }
}
