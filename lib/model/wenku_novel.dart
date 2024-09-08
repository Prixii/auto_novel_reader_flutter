part of 'model.dart';

@freezed
class WenkuNovel with _$WenkuNovel {
  const factory WenkuNovel.wenkuNovelOutline(
    String id,
    String title,
    String titleZh,
    String cover, {
    String? favored,
  }) = WenkuNovelOutline;

  const factory WenkuNovel.wenkuNovelDto(
    String id,
    String title,
    String titleZh, {
    String? cover,
    @Default([]) List<String> authors,
    @Default([]) List<String> artists,
    @Default([]) List<String> keywords,
    String? publisher,
    String? imprint,
    int? latestPublishAt,
    required String level, // '一般向', '成人向', '严肃向'
    required String introduction,
    @Default([]) List<String> webIds,
    @Default([]) List<WenkuVolumeDto> volumes,
    @Default({}) Map<String, String> glossary,
    required int visited,
    String? favored,
    @Default([]) List<String> volumeZh,
    @Default([]) List<VolumeJpDto> volumeJp,
  }) = WenkuNovelDto;

  const factory WenkuNovel.wenkuVolumeDto(
    String asin,
    String title, {
    String? titleZh,
    String? cover,
    String? coverHires,
    String? publisher,
    String? imprint,
    int? publishAt,
  }) = WenkuVolumeDto;

  const factory WenkuNovel.volumeJpDto(
    String volumeId,
    int total,
    int baidu,
    int youdao,
    int gpt,
    int sakura,
  ) = VolumeJpDto;

  const factory WenkuNovel.amazonNovel(
    String title,
    bool r18, {
    String? titleZh,
    @Default([]) List<String> authors,
    @Default([]) List<String> artists,
    required String introduction,
    @Default([]) List<WenkuVolumeDto> volumes,
  }) = AmazonNovel;
}

@freezed
class PresetKeywords with _$PresetKeywords {
  const factory PresetKeywords.group({
    required String title,
    @Default([]) List<String> presetKeywords,
  }) = PresetKeywordsGroup;

  const factory PresetKeywords.explanation({
    required String word,
    required String explanation,
  }) = PresetKeywordsExplanation;

  const factory PresetKeywords.keywords({
    @Default([]) List<PresetKeywordsGroup> groups,
    @Default([]) List<PresetKeywordsExplanation> explanations,
  }) = Keywords;
}

final presetKeywordsNonR18 = Keywords(
  groups: _groupsNonR18,
  explanations: _explanationsNonR18,
);

final presetKeywordsR18 = Keywords(
  groups: _groupsR18,
  explanations: _explanationsR18,
);

final _groupsNonR18 = <PresetKeywordsGroup>[
  const PresetKeywordsGroup(
    title: '视角',
    presetKeywords: ['男主视角', '女主视角', 'TS视角', '群像'],
  ),
  const PresetKeywordsGroup(
    title: '人物',
    presetKeywords: [
      '青梅竹马',
      '兄妹',
      '姐弟',
      '亲子',
      '师生',
      '萝莉',
      '人外',
      '伪娘',
      '龙傲天',
      '傲娇',
      '病娇',
      '恶役',
    ],
  ),
  const PresetKeywordsGroup(
    title: '世界',
    presetKeywords: [
      '现代',
      '科幻',
      '奇幻',
      '历史',
      '末日',
      '校园',
      '游戏',
      '职场',
      '中华',
      '和风',
    ],
  ),
  const PresetKeywordsGroup(
    title: '氛围',
    presetKeywords: ['治愈', '欢乐', '扭曲', '残酷', '致郁', '猎奇', '悬疑'],
  ),
  const PresetKeywordsGroup(
    title: '主题',
    presetKeywords: [
      '纯爱',
      '后宫',
      '逆后宫',
      '百合',
      '耽美',
      'NTR',
      '战斗',
      '冒险',
      '异能',
      '机战',
      '战争',
      '经营',
      '日常',
      '推理',
      '竞技',
      '旅行',
      '穿越',
      '复仇',
      '误解系',
      '活该系',
    ],
  ),
  const PresetKeywordsGroup(
    title: '其他',
    presetKeywords: ['动画化', '漫画化', '衍生作'],
  ),
];

final _explanationsNonR18 = <PresetKeywordsExplanation>[
  const PresetKeywordsExplanation(
    word: '男主视角, 女主视角, TS视角, 群像',
    explanation: '小说的主视角，绝大多数情况只选择其中一个。单纯双主角不要添加“群像”。',
  ),
  const PresetKeywordsExplanation(
    word: '龙傲天',
    explanation: '不分男女，但必须得是主视角。',
  ),
  const PresetKeywordsExplanation(
    word: '科幻',
    explanation: '科幻风格的世界观，例如近未来的地球、空想科学的异世界、宇宙。',
  ),
  const PresetKeywordsExplanation(
    word: '奇幻',
    explanation: '奇幻风格的世界观，例如常见的异世界。',
  ),
  const PresetKeywordsExplanation(
    word: '游戏',
    explanation: '小说的主要场地在游戏中，包括现实游戏和穿越到游戏世界，注意并不是有状态面板就算是游戏世界。',
  ),
  const PresetKeywordsExplanation(
    word: '治愈',
    explanation: '“治愈”表示剧情轻松，例如慢生活系。',
  ),
  const PresetKeywordsExplanation(
    word: '扭曲, 残酷, 致郁, 猎奇',
    explanation:
        '“扭曲”表示存在情感纠葛的剧情，简单的多角恋党争不算。“残酷”表示存在黑暗的设定或情节，例如死亡游戏或大逃杀。“致郁”表示存在让人郁闷的情节，注意致郁不一定意味着角色死亡。“猎奇”表示存在重口或血腥描写。',
  ),
  const PresetKeywordsExplanation(
    word: '后宫, 逆后宫, 百合, 耽美',
    explanation: '这几个标签都采用广义解释。伪后宫、伪百合都可以使用。',
  ),
  const PresetKeywordsExplanation(
    word: '穿越',
    explanation: '转生和穿越都可以使用这个标签。',
  ),
  const PresetKeywordsExplanation(
    word: '动画化, 漫画化, 衍生作',
    explanation: '只有小说是本体的情况，才可以添加“动画化”和“漫画化”标签。如果本体是其他类型的作品，请添加“衍生作”。',
  ),
];

final _groupsR18 = <PresetKeywordsGroup>[];

final _explanationsR18 = <PresetKeywordsExplanation>[];

List<WenkuNovelOutline> parseToWenkuNovelOutline(dynamic body) {
  try {
    final items = body['items'] as List<dynamic>;
    var wenkuNovelOutlines = <WenkuNovelOutline>[];
    for (final item in items) {
      wenkuNovelOutlines.add(
        WenkuNovelOutline(
          item['id'],
          item['title'],
          item['titleZh'],
          item['cover'],
          favored: item['favored'],
        ),
      );
    }
    return wenkuNovelOutlines;
  } catch (e, stackTrace) {
    talker.error(e, stackTrace);
    return [];
  }
}
