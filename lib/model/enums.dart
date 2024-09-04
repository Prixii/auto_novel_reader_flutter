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
        return '绿站';
      case HomeViews.reader:
        return '阅读';
      case HomeViews.settings:
        return '设置';
    }
  }
}

enum ProgressType {
  parsingEpub(0);

  final int value;

  const ProgressType(this.value);

  factory ProgressType.fromIndex(int value) =>
      ProgressType.values.firstWhere((element) => element.value == value,
          orElse: () => throw Exception('Invalid index'));
}

enum SearchSortType {
  create,
  update;
}

enum UserRole {
  admin,
  maintainer,
  trusted,
  normal,
  banned;
}

enum Language {
  jp,
  zh,
  zhJp,
  jpZh;

  String get kebabName => switch (this) {
        Language.jp => 'jp',
        Language.zh => 'zh',
        Language.zhJp => 'zh-jp',
        Language.jpZh => 'jp-zh',
      };
}

enum TranslationMode {
  priority,
  parallel,
}

enum TranslationSource {
  baidu,
  youdao,
  gpt,
  sakura;

  String get zhName => switch (this) {
        TranslationSource.baidu => '百度',
        TranslationSource.youdao => '有道',
        TranslationSource.gpt => 'GPT',
        TranslationSource.sakura => 'Sakura',
      };
}

enum ReadType {
  epub,
  web,
  none,
}

enum NovelType {
  web,
  wenku,
  local,
}

enum DownloadType {
  downloaded,
  downloading,
  parsing,
  failed,
  none,
}

enum NovelProvider {
  kakuyomu,
  syosetu,
  novelup,
  hameln,
  pixiv,
  alphapolis;

  String get zhName => switch (this) {
        NovelProvider.kakuyomu => 'Kakuyomu',
        NovelProvider.syosetu => '成为小说家吧',
        NovelProvider.novelup => 'Novelup',
        NovelProvider.hameln => 'Hameln',
        NovelProvider.pixiv => 'Pixiv',
        NovelProvider.alphapolis => 'Alphapolis'
      };

  String get defaultProviders => NovelProvider.values.join(',');
}

enum NovelCategory {
  all,
  serial,
  finished,
  short;

  String get zhName => switch (this) {
        NovelCategory.all => '全部',
        NovelCategory.serial => '连载中',
        NovelCategory.finished => '已完结',
        NovelCategory.short => '短篇',
      };
  static int indexByZhName(String name) {
    for (var i = 0; i < NovelCategory.values.length; i++) {
      if (NovelCategory.values[i].zhName == name) {
        return i;
      }
    }
    return -1;
  }
}

enum WebTranslationSource {
  all,
  gpt,
  sakura;

  String get zhName => switch (this) {
        WebTranslationSource.all => '全部',
        WebTranslationSource.gpt => 'GPT',
        WebTranslationSource.sakura => 'Sakura'
      };
  static int indexByZhName(String name) {
    for (var i = 0; i < WebTranslationSource.values.length; i++) {
      if (WebTranslationSource.values[i].zhName == name) {
        return i;
      }
    }
    return -1;
  }
}

enum WebNovelOrder {
  update,
  visit,
  relate;

  String get zhName => switch (this) {
        WebNovelOrder.update => '更新',
        WebNovelOrder.visit => '点击',
        WebNovelOrder.relate => '相关',
      };

  static int indexByZhName(String name) {
    for (var i = 0; i < WebNovelOrder.values.length; i++) {
      if (WebNovelOrder.values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return -1; // 如果没有找到，返回 -1
  }
}

enum WenkuNovelLevel {
  general,
  serious;

  String get zhName => switch (this) {
        WenkuNovelLevel.general => '一般向',
        WenkuNovelLevel.serious => '严肃向',
      };
  static int indexByZhName(String name) {
    // for (var i = 0; i < WenkuNovelLevel.values.length; i++) {
    //   if (WenkuNovelLevel.values[i].zhName == name) {
    //     return i; // 返回匹配的索引
    //   }
    // }
    // return -1; // 如果没有找到，返回 -1
    if (name == '一般向') return 1;
    if (name == '严肃向') return 3;
    return -1;
  }
}
