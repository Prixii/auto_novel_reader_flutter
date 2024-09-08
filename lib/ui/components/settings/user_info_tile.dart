import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
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
    final state = readUserCubit(context).state;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Text(
            '@${state.username}',
            style: styleManager.titleSmall(context),
          ),
          const SizedBox(width: 8.0),
          Text(
            parseTimeStamp((state.createAt ?? 0) * 1000),
            style: styleManager.tipText(context),
          ),
          Expanded(child: Container()),
          IconButton(
              onPressed: () => tryLogout(context),
              icon: const Icon(UniconsLine.signout),
              color: styleManager.colorScheme(context).error),
        ],
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.9,
              minHeight: screenSize.height * 0.9,
              minWidth: screenSize.width),
          child: const AuthTab(),
        );
      },
    );
  }

  void tryLogout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定登出'),
        content: const Text('确定要登出吗?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () {
                readUserCubit(context).signOut();
                Navigator.of(context).pop(true);
              },
              child: const Text('确定')),
        ],
      ),
    );
  }
}
