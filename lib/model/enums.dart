enum HomeViews {
  webHome(0),
  reader(1),
  settings(2);

  final int value;

  const HomeViews(this.value);

  factory HomeViews.fromIndex(int value) =>
      HomeViews.values.firstWhere((element) => element.value == value);

  String get nameByValue {
    switch (this) {
      case HomeViews.webHome:
        return '网页';
      case HomeViews.reader:
        return '阅读';
      case HomeViews.settings:
        return '设置';
    }
  }
}
