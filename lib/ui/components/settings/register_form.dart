import 'package:auto_novel_reader_flutter/ui/components/settings/auth_tab.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/custom_text_field.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late TextEditingController _emailOrUsernameController,
      _passwordController,
      _confirmPasswordController;
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _emailOrUsernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField('用户名/邮箱', _emailOrUsernameController, inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ]),
        space,
        buildTextField('密码', _passwordController, obscureText: true),
        space,
        buildTextField('确认密码', _passwordController, obscureText: true),
        space,
        buildRoundButton(() => _doRegister(context)),
      ],
    );
  }

  void _doRegister(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formFinished()) {
      // TODO
    } else {
      _showToast(context);
    }
  }

  bool _formFinished() {
    return (_emailOrUsernameController.text != '') &&
        (_passwordController.text != '');
  }

  void _showToast(BuildContext context) {
    final isPasswordMatch =
        _passwordController.text == _confirmPasswordController.text;
    (!_formFinished() || isPasswordMatch)
        ? showWarnToast('请填写完整信息')
        : showWarnToast('两次密码不一致');
  }
}
