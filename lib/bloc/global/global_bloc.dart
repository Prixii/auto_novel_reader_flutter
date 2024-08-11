import 'package:auto_novel_reader_flutter/ui/view/splash.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_bloc.freezed.dart';
part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(const _Initial()) {
    on<GlobalEvent>((event, emit) async {
      await event.map(
        login: (event) async => await _onLogin(event, emit),
        logout: (event) async => await _onLogout(event, emit),
        register: (event) async => await _onRegister(event, emit),
        switchNavigationDestination: (event) async =>
            await _onSwitchNavigationDestination(event, emit),
        initConfig: (event) async => await _onInitConfig(event, emit),
        getUserInfo: (event) async => await _onGetUserInfo(event, emit),
      );
    });
  }

  _onLogin(_Login event, Emitter<GlobalState> emit) async {
    // emit(state.copyWith(isLogin: true));
    // final phone = event.phone;
    // final password = event.password;
    // final md5Password = md5.convert(utf8.encode(password)).toString();
    // final shouldAutoLogin = event.isRememberMeChecked;
    // final isAutoLogin = event.isAutoLogin;
    // final response =
    //     await authApi.login(LoginData(phone: phone, password: md5Password));
    // emit(state.copyWith(isLogin: false));
    // if (response.statusCode != StatusCode.success.value) {
    //   Fluttertoast.showToast(
    //       msg: Lang.current.wrongUsernameOrPassword,
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   clearSharedPreference();
    //   if (isAutoLogin) {
    //     router.goNamed('hello');
    //   }
    //   return;
    // }

    // final token = response.data!.token;
    // final role = Role.fromValue(response.data!.role);

    // emit(state.copyWith(
    //     token: token,
    //     role: role,
    //     mineMenus: defaultMineMenu,
    //     communityMenus: generateMenu(role)));

    // prefs.setString('phone', phone);
    // prefs.setString('password', password);
    // prefs.setBool('autoLogin', shouldAutoLogin);

    _afterLogin();
  }

  _onLogout(_Logout event, Emitter<GlobalState> emit) {
    clearSharedPreference();
    emit(const _Initial());
    // TODO router.goNamed('hello');
  }

  _onRegister(_Register event, Emitter<GlobalState> emit) async {}

  _onSwitchNavigationDestination(
      _SwitchNavigationDestination event, Emitter<GlobalState> emit) {
    emit(state.copyWith(destinationIndex: event.destinationIndex));
  }

  _onInitConfig(_InitConfig event, Emitter<GlobalState> emit) {}

  void _afterLogin() async {
    add(const GlobalEvent.initConfig());
    // TODO router.goNamed('home');
    add(const GlobalEvent.getUserInfo());
  }

  _onGetUserInfo(_GetUserInfo event, Emitter<GlobalState> emit) async {}
}
