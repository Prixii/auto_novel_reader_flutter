import 'dart:async';

import 'package:auto_novel_reader_flutter/network/api_client.dart';
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
  var coolDown = 0;
  var sending = false;
  late TextEditingController _emailController,
      _passwordController,
      _confirmPasswordController,
      _usernameController,
      _emailCodeController;
  bool isRememberMeChecked = false;
  bool requesting = false;
  Timer? _timer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailCodeController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _emailCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField('邮箱', _emailController, validator: (value) {
            if (value == null || !_isValidEmail) {
              return '请输入正确的邮箱';
            }
            return null;
          }),
          space,
          _buildEmailCodeField(),
          space,
          buildTextField(
            '用户名',
            _usernameController,
            maxLines: 1,
            inputFormatters: _usernameFormatter,
            validator: (value) {
              if (value == null || value.length < 3 || value.length > 15) {
                return '用户名应为 3~15 个字符';
              }
              return null;
            },
          ),
          space,
          buildTextField('密码', _passwordController,
              obscureText: true,
              inputFormatters: _passwordFormatter, validator: (value) {
            if (value == null || value.length < 8) {
              return '密码至少为 8 个字符';
            }
            return null;
          }),
          space,
          buildTextField('确认密码', _confirmPasswordController, obscureText: true,
              validator: (value) {
            if (value != _passwordController.text) {
              return '两次输入的密码不一致';
            }
            return null;
          }),
          space,
          requesting
              ? buildLoadingButton()
              : buildRoundButton(() => _doSignUp()),
          const SizedBox(
            height: 328,
          )
        ],
      ),
    );
  }

  Widget _buildEmailCodeField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: buildTextField(
              keyboardType: TextInputType.number,
              '邮箱验证码',
              _emailCodeController,
              inputFormatters: _emailCodeFormatter, validator: (value) {
            if (value == null || value.length != 6) {
              return '验证码应为6位数字';
            }
            return null;
          }),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 128,
          child: FilledButton(
            onPressed: isCoolingDown ? null : _requestEmailCode,
            child: sending
                ? const Text('发送中')
                : isCoolingDown
                    ? Text('请等待 ${coolDown}s')
                    : const Text('发送验证码'),
          ),
        )
      ],
    );
  }

  void _requestEmailCode() async {
    if (coolDown != 0) return;
    if (!_isValidEmail) {
      showWarnToast('请输入正确的邮箱地址');
      return;
    }
    sending = true;
    final response =
        await apiClient.authService.postVerifyEmail(_emailController.text);
    sending = false;
    if (response.statusCode != 200) {
      showWarnToast('验证码发送失败, Code: ${response.statusCode}');
    } else {
      showSucceedToast('验证码已发送');
      _startTimer();
    }
  }

  void _startTimer() {
    if (coolDown != 0 || _timer != null) return;
    coolDown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (coolDown > 0) {
        setState(() {
          coolDown--;
        });
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void _doSignUp() async {
    if (requesting) return;
    if (!_formKey.currentState!.validate()) {
      showWarnToast('请填写完整信息喵~');
      return;
    }
    if (!_isPasswordMatch) {
      showWarnToast('两次密码不一致');
    } else {
      setState(() {
        requesting = true;
      });
      final result = await readUserCubit(context).signUp(
          email: _emailController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          emailCode: _emailCodeController.text);
      setState(() {
        requesting = false;
      });
      if (result) {
        showSucceedToast('注册成功');
        if (mounted) Navigator.pop(context);
      }
    }
  }

  List<TextInputFormatter> get _usernameFormatter {
    return [
      LengthLimitingTextInputFormatter(15),
      FilteringTextInputFormatter.deny(RegExp(r"\s")),
    ];
  }

  List<TextInputFormatter> get _emailCodeFormatter => [
        LengthLimitingTextInputFormatter(6),
        FilteringTextInputFormatter.digitsOnly,
      ];
  List<TextInputFormatter> get _passwordFormatter => [
        FilteringTextInputFormatter.deny(RegExp(r"\s")),
      ];

  bool get _isValidEmail => emailRegex.hasMatch(_emailController.text);

  bool get isCoolingDown => coolDown != 0;

  bool get _isPasswordMatch =>
      _passwordController.text == _confirmPasswordController.text;
}
