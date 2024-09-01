import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/ui/components/settings/auth_tab.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class UserInfoTile extends StatelessWidget {
  const UserInfoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.token == null
            ? _buildForGuest(context)
            : _buildForUser(context);
      },
    );
  }

  Widget _buildForGuest(BuildContext context) {
    return IconOption(
      icon: UniconsLine.user,
      text: '点我登录',
      onTap: () => login(context),
    );
  }

  Widget _buildForUser(BuildContext context) {
    return Container();
  }

  Future<void> login(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.8,
              minHeight: screenSize.height * 0.8,
              minWidth: screenSize.width),
          child: const AuthTab(),
        );
      },
    );
  }
}
