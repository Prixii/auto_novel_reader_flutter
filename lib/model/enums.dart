import 'package:flutter/material.dart';

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

extension ThemeModeExt on ThemeMode {
  String get zhName => switch (this) {
        ThemeMode.system => '跟随系统',
        ThemeMode.light => '浅色',
        ThemeMode.dark => '深色',
      };
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

  String get zhName => switch (this) {
        SearchSortType.create => '收藏时间',
        SearchSortType.update => '更新时间',
      };
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

  String get zhName => switch (this) {
        Language.jp => '日文',
        Language.zh => '中文',
        Language.zhJp => '中日',
        Language.jpZh => '日中'
      };
}

enum TranslationMode {
  priority,
  parallel;

  String get zhName => switch (this) {
        TranslationMode.priority => '优先',
        TranslationMode.parallel => '并列',
      };
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
  local;

  String get zhName => switch (this) {
        NovelType.web => '网络小说',
        NovelType.wenku => '文库小说',
        NovelType.local => '本地小说'
      };
}

enum DownloadStatus {
  redirecting,
  downloading,
  parsing,
  failed,
  succeed,
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

enum WebNovelLevel {
  all,
  general,
  r18;

  String get zhName => switch (this) {
        WebNovelLevel.general => '一般向',
        WebNovelLevel.r18 => 'R18',
        WebNovelLevel.all => '全部',
      };
  static int indexByZhName(String name) {
    // for (var i = 0; i < WenkuNovelLevel.values.length; i++) {
    //   if (WenkuNovelLevel.values[i].zhName == name) {
    //     return i; // 返回匹配的索引
    //   }
    // }
    // return -1; // 如果没有找到，返回 -1
    if (name == '全部') return 0;
    if (name == '一般向') return 1;
    if (name == 'R18') return 2;
    return -1;
  }
}

enum WenkuNovelLevel {
  general,
  adult,
  serious;

  String get zhName => switch (this) {
        WenkuNovelLevel.general => '一般向',
        WenkuNovelLevel.adult => '成人向',
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
    if (name == '成人向') return 2;
    if (name == '严肃向') return 3;
    return -1;
  }

  static List<WenkuNovelLevel> get oldAss => [general, adult, serious];
  static List<WenkuNovelLevel> get youngAss => [general, serious];
}

enum NovelStatus {
  all,
  serial,
  finished,
  short;

  String get zhName => switch (this) {
        NovelStatus.all => '全部',
        NovelStatus.short => '短篇',
        NovelStatus.serial => '连载',
        NovelStatus.finished => '完结',
      };
  static int indexByZhName(String name) {
    for (var i = 0; i < NovelStatus.values.length; i++) {
      if (NovelStatus.values[i].zhName == name) {
        return i;
      }
    }
    return -1;
  }
}

enum SyosetuGenre {
  romanceFantasy, // 恋爱：异世界
  romanceRealWorld, // 恋爱：现实世界
  highFantasy, // 幻想：高幻想
  lowFantasy, // 幻想：低幻想
  pureLiterature, // 文学：纯文学
  humanDrama, // 文学：人性剧
  historyLiterature, // 文学：历史
  mysteryLiterature, // 文学：推理
  horrorLiterature, // 文学：恐怖
  actionLiterature, // 文学：动作
  comedyLiterature, // 文学：喜剧
  vrGameSciFi, // 科幻：VR游戏
  cosmicSciFi, // 科幻：宇宙
  speculativeSciFi, // 科幻：空想科学
  thrillerSciFi, // 科幻：惊悚
  fairyTale, // 其他：童话
  poetry, // 其他：诗
  prose, // 其他：散文
  others; // 其他：其他

  String get zhName => switch (this) {
        SyosetuGenre.romanceFantasy => '恋爱：异世界',
        SyosetuGenre.romanceRealWorld => '恋爱：现实世界',
        SyosetuGenre.highFantasy => '幻想：高幻想',
        SyosetuGenre.lowFantasy => '幻想：低幻想',
        SyosetuGenre.pureLiterature => '文学：纯文学',
        SyosetuGenre.humanDrama => '文学：人性剧',
        SyosetuGenre.historyLiterature => '文学：历史',
        SyosetuGenre.mysteryLiterature => '文学：推理',
        SyosetuGenre.horrorLiterature => '文学：恐怖',
        SyosetuGenre.actionLiterature => '文学：动作',
        SyosetuGenre.comedyLiterature => '文学：喜剧',
        SyosetuGenre.vrGameSciFi => '科幻：VR游戏',
        SyosetuGenre.cosmicSciFi => '科幻：宇宙',
        SyosetuGenre.speculativeSciFi => '科幻：空想科学',
        SyosetuGenre.thrillerSciFi => '科幻：惊悚',
        SyosetuGenre.fairyTale => '其他：童话',
        SyosetuGenre.poetry => '其他：诗',
        SyosetuGenre.prose => '其他：散文',
        SyosetuGenre.others => '其他：其他',
      };

  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum KakuyomuGenre {
  comprehensive, // 综合
  fantasy, // 异世界幻想
  modernFantasy, // 现代幻想
  sciFi, // 科幻
  romance, // 恋爱
  romanticComedy, // 浪漫喜剧
  modernDrama, // 现代戏剧
  horror, // 恐怖
  mystery, // 推理
  prose, // 散文·纪实
  history, // 历史·时代·传奇
  critique, // 创作论·评论
  poetry; // 诗·童话·其他

  // 方法: 获取中文名称
  String get zhName => switch (this) {
        KakuyomuGenre.comprehensive => '综合',
        KakuyomuGenre.fantasy => '异世界幻想',
        KakuyomuGenre.modernFantasy => '现代幻想',
        KakuyomuGenre.sciFi => '科幻',
        KakuyomuGenre.romance => '恋爱',
        KakuyomuGenre.romanticComedy => '浪漫喜剧',
        KakuyomuGenre.modernDrama => '现代戏剧',
        KakuyomuGenre.horror => '恐怖',
        KakuyomuGenre.mystery => '推理',
        KakuyomuGenre.prose => '散文·纪实',
        KakuyomuGenre.history => '历史·时代·传奇',
        KakuyomuGenre.critique => '创作论·评论',
        KakuyomuGenre.poetry => '诗·童话·其他',
      };

  // 方法: 根据中文名称获取索引
  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum SyosetuIsekaiGenre {
  romance, // 恋爱
  fantasy, // 幻想
  literatureSciFiOthers; // 文学/科幻/其他

  String get zhName => switch (this) {
        SyosetuIsekaiGenre.romance => '恋爱',
        SyosetuIsekaiGenre.fantasy => '幻想',
        SyosetuIsekaiGenre.literatureSciFiOthers => '文学/科幻/其他',
      };

  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum SyosetuNovelRange {
  total, // 总计
  yearly, // 每年
  quarter, // 每月
  monthly, // 每月
  weekly, // 每周
  daily; // 每日

  String get zhName => switch (this) {
        SyosetuNovelRange.total => '总计',
        SyosetuNovelRange.yearly => '每年',
        SyosetuNovelRange.quarter => '季度',
        SyosetuNovelRange.monthly => '每月',
        SyosetuNovelRange.weekly => '每周',
        SyosetuNovelRange.daily => '每日',
      };

  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum NovelRange {
  total, // 总计
  yearly, // 每年
  quarter, // 每月
  monthly, // 每月
  weekly, // 每周
  daily; // 每日

  String get zhName => switch (this) {
        NovelRange.total => '总计',
        NovelRange.yearly => '每年',
        NovelRange.quarter => '季度',
        NovelRange.monthly => '每月',
        NovelRange.weekly => '每周',
        NovelRange.daily => '每日',
      };

  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum RankCategory {
  syosetuGenre, // 成为小说家:流派
  syosetuComprehensive, // 成为小说家：综合
  syosetuIsekai, // 成为小说家：异世界转移/转生
  kakuyomuGenre; // Kakuyomu：流派

  String get zhName => switch (this) {
        RankCategory.syosetuGenre => '成为小说家: 流派',
        RankCategory.syosetuComprehensive => '成为小说家: 综合',
        RankCategory.syosetuIsekai => '成为小说家: 异世界转移/转生',
        RankCategory.kakuyomuGenre => 'Kakuyomu: 流派',
      };

  static int? indexFromZhName(String name) {
    for (var i = 0; i < values.length; i++) {
      if (values[i].zhName == name) {
        return i; // 返回匹配的索引
      }
    }
    return null; // 如果没有找到，返回 null
  }
}

enum NovelContentType {
  text,
  image,
  ruby,
  h1,
  h2,
  h3,
}

enum NovelRenderType {
  streaming,
  paged;

  String get zhName => switch (this) {
        NovelRenderType.streaming => '流式',
        NovelRenderType.paged => '翻页',
      };
}

enum LoadingStatus { loading, failed, serverError }

enum RequestLabel {
  // 主页
  loadWebFavored,
  loadWebMostVisited,
  loadWenkuLatestUpdated,
  //
  loadNovelDetail,
  loadNovelChapter,
  loadNextPageWeb,
  // 搜索
  searchWenku,
  searchWeb,
  searchRank,
  //
  loadHistory,
}

enum WebNovelContentType {
  original,
  translation,
  image,
}
