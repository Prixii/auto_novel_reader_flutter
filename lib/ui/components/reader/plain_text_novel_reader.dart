import 'dart:math';

import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/chapter_list.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlainTextNovelReaderContainer extends StatelessWidget {
  const PlainTextNovelReaderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WebHomeBloc, WebHomeState, ChapterDto?>(
      selector: (state) {
        return state.currentChapterDto;
      },
      builder: (context, dto) {
        return Scaffold(
          appBar: AppBar(
            title: Text(dto?.titleJp ?? dto?.titleZh ?? ''),
            shadowColor: styleManager.colorScheme.shadow,
            backgroundColor: styleManager.colorScheme.secondaryContainer,
          ),
          drawer: Drawer(
            child: BlocSelector<WebHomeBloc, WebHomeState, WebNovelDto?>(
              selector: (state) {
                return state.webNovelDtoMap[
                    '${state.currentNovelProviderId}${state.currentNovelId}'];
              },
              builder: (context, novelDto) {
                final state = readWebHomeBloc(context).state;
                final bookKey =
                    '${state.currentNovelProviderId}${state.currentNovelId}';
                return ChapterList(
                  tocList: novelDto?.toc ?? [],
                  readMode: true,
                  bookKey: bookKey,
                );
              },
            ),
          ),
          body: dto == null
              ? const Center(child: CircularProgressIndicator())
              : PlainTextNovelReader(dto: dto),
        );
      },
    );
  }
}

class PlainTextNovelReader extends StatelessWidget {
  const PlainTextNovelReader({
    super.key,
    required this.dto,
  });

  final ChapterDto dto;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        if (Scaffold.of(context).isDrawerOpen) return;
        readWebHomeBloc(context).add(const WebHomeEvent.closeNovel());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            Text(
              dto.titleJp ?? '',
              style: styleManager.primaryColorTitleLarge,
            ),
            Text(
              dto.titleZh ?? '',
              style: styleManager.titleSmall,
            ),
            const Divider(),
            NovelRender(
              chapterDto: dto,
            )
          ],
        ),
      ),
    );
  }
}

class NovelRender extends StatelessWidget {
  const NovelRender({
    super.key,
    required this.chapterDto,
  });
  final ChapterDto chapterDto;

  @override
  Widget build(BuildContext context) {
    final maxLength = max(chapterDto.originalParagraphs!.length,
        chapterDto.youdaoParagraphs?.length ?? 0);
    final config = readConfigCubit(context).state.webNovelConfig;
    final parallel = config.translationMode == TranslationMode.parallel;
    final lang = config.language;
    final order = config.translationSourcesOrder;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        late List<TextSpan> spans;
        switch (config.language) {
          case Language.zh:
            spans = buildTranslationTextSpans(index, parallel, order, lang);
            break;
          case Language.jp:
            spans = [buildOriginalTextSpan(index, lang)];
            break;
          case Language.jpZh:
            spans = [
              buildOriginalTextSpan(index, lang),
              ...buildTranslationTextSpans(index, parallel, order, lang)
            ];

          case Language.zhJp:
            spans = [
              ...buildTranslationTextSpans(index, parallel, order, lang),
              buildOriginalTextSpan(index, lang),
            ];
        }

        return RichText(
          text: TextSpan(
            children: spans,
          ),
        );
      },
      itemCount: maxLength,
    );
  }

  List<TextSpan> buildTranslationTextSpans(
      int index, bool parallel, List<TranslationSource> order, Language lang) {
    var paragraphList = <String>[];
    if (parallel) {
      for (final source in order) {
        switch (source) {
          case TranslationSource.youdao:
            if (chapterDto.youdaoParagraphs != null &&
                index < chapterDto.youdaoParagraphs!.length) {
              paragraphList.add(chapterDto.youdaoParagraphs![index]);
            }
          case TranslationSource.baidu:
            if (chapterDto.baiduParagraphs != null &&
                index < chapterDto.baiduParagraphs!.length) {
              paragraphList.add(chapterDto.baiduParagraphs![index]);
            }
          case TranslationSource.gpt:
            if (chapterDto.gptParagraphs != null &&
                index < chapterDto.gptParagraphs!.length) {
              paragraphList.add(chapterDto.gptParagraphs![index]);
            }
          case TranslationSource.sakura:
            if (chapterDto.sakuraParagraphs != null &&
                index < chapterDto.sakuraParagraphs!.length) {
              paragraphList.add(chapterDto.sakuraParagraphs![index]);
            }
        }
      }
      var spans = <TextSpan>[];
      for (int i = 0; i < paragraphList.length; i++) {
        var text = paragraphList[i];
        var shouldWrap = false;
        if (i != paragraphList.length - 1) {
          // 不是最后一个
          shouldWrap = true;
        } else if (lang == Language.zhJp) {
          // 先中文再日文
          shouldWrap = true;
        }
        spans.add(buildTextSpan(text, wrap: shouldWrap));
      }
      return spans;
    } else {
      String? text;
      for (final source in order) {
        switch (source) {
          case TranslationSource.youdao:
            if (chapterDto.youdaoParagraphs != null &&
                index < chapterDto.youdaoParagraphs!.length) {
              text = chapterDto.youdaoParagraphs![index];
            }
          case TranslationSource.baidu:
            if (chapterDto.baiduParagraphs != null &&
                index < chapterDto.baiduParagraphs!.length) {
              text = chapterDto.baiduParagraphs![index];
            }
          case TranslationSource.gpt:
            if (chapterDto.gptParagraphs != null &&
                index < chapterDto.gptParagraphs!.length) {
              text = chapterDto.gptParagraphs![index];
            }
          case TranslationSource.sakura:
            if (chapterDto.sakuraParagraphs != null &&
                index < chapterDto.sakuraParagraphs!.length) {
              text = chapterDto.sakuraParagraphs![index];
            }
        }
        if (text != null) {
          break;
        }
      }
      final shouldWrap = lang == Language.zhJp;
      return [buildTextSpan(text!, wrap: shouldWrap)];
    }
  }

  TextSpan buildOriginalTextSpan(int index, Language lang) {
    return buildTextSpan(
      chapterDto.originalParagraphs![index],
      grey: lang != Language.jp,
      wrap: lang == Language.jpZh,
    );
  }

  TextSpan buildTextSpan(
    String text, {
    bool grey = false,
    bool wrap = false,
  }) {
    return TextSpan(
      text: text + (wrap ? '\n' : ''),
      style: grey ? styleManager.originalText : styleManager.zhText,
    );
  }
}
