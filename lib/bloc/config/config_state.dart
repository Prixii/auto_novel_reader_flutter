part of 'config_cubit.dart';

@freezed
class ConfigState with _$ConfigState {
  const factory ConfigState.initial({
    @Default(false) bool slideShift, // 水平滑动翻页
    @Default(false) bool showErrorInfo, // 如果 html 元素加载失败，则显示错误信息
    @Default(true) bool volumeKeyShift, // 音量键控制翻页
    @Default(1) int helloPageIndex, // 欢迎页,
    @Default('books.fishhawk.top') String host, // 网站地址
    @Default(WebNovelConfig()) WebNovelConfig webNovelConfig, // web 阅读内容设置
    @Default(true) bool preloadNovel, // 预加载小说
    @Default(ThemeMode.system) ThemeMode themeMode,
  }) = _Initial;

  factory ConfigState.fromJson(Map<String, dynamic> json) =>
      _$ConfigStateFromJson(json);
}
