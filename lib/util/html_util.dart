import 'package:html/parser.dart';

const htmlUtil = _HtmlUtil();

class _HtmlUtil {
  const _HtmlUtil();

  final maxLength = 2000;

  List<String> pretreatHtml(String html, String url) {
    var htmlPartList = <String>[];
    var rawHtml = html;
    final paragraphList = paragraphExtractor(rawHtml);
    final combinedParagraph = combineParagraph(paragraphList);

    for (var paragraph in combinedParagraph) {
      final redirectedParagraph = redirectSource(paragraph, url);
      htmlPartList.add(redirectedParagraph);
    }

    return htmlPartList;
  }

  String redirectSource(String html, String url) {
    return html
        .replaceAll('src="', 'src="file://$url/')
        .replaceAll('href="', 'href="file://$url/')
        .replaceAll('../', '');
  }

  @Deprecated('use paragraphExtractor instead')
  String removeHeadSection(String html) {
    int startIndex = html.indexOf('<head>');
    if (startIndex == -1) return html;

    int endIndex = html.indexOf('</head>') + '</head>'.length;
    if (endIndex == -1) return html;

    return html.substring(0, startIndex) + html.substring(endIndex);
  }

  /// 获取所有段落
  List<String> paragraphExtractor(String htmlData) {
    final document = parse(htmlData);
    final paragraphElements = document.querySelectorAll('p');
    final paragraphList = <String>[];
    for (var para in paragraphElements) {
      paragraphList.add(para.outerHtml);
    }
    return paragraphList;
  }

  List<String> combineParagraph(List<String> paragraphList) {
    final combinedList = <String>[];
    var tempCombinedPara = '';
    for (var paragraph in paragraphList) {
      if (tempCombinedPara.length + paragraph.length > maxLength) {
        combinedList.add(tempCombinedPara);
        tempCombinedPara = '';
      }
      tempCombinedPara += paragraph;
    }
    combinedList.add(tempCombinedPara);
    return combinedList;
  }
}
