import 'package:html/dom.dart';
import 'package:html/parser.dart';

const htmlUtil = _HtmlUtil();

class _HtmlUtil {
  const _HtmlUtil();

  final maxLength = 2000;

  List<String> pretreatHtml(String html, String url) {
    var htmlPartList = <String>[];
    var rawHtml = html;
    final elementList = elementExtractor(rawHtml);
    final combinedParagraph = combineParagraph(elementList);

    for (var paragraph in combinedParagraph) {
      final redirectedParagraph = redirectSource(paragraph, url);
      final convertedParagraph = convertXlinkToSrc(redirectedParagraph);
      htmlPartList.add(convertedParagraph);
    }

    return htmlPartList;
  }

  String redirectSource(String html, String url) {
    return html
        .replaceAll('src="', 'src="file://$url/')
        .replaceAll('href="', 'href="file://$url/')
        .replaceAll('../', '');
  }

  String convertXlinkToSrc(String html) {
    final RegExp regex = RegExp(r'<img\s+([^>]*)xlink:href="([^"]*)"');
    return html.replaceAllMapped(regex, (match) {
      final attributes = match.group(1)!;
      final href = match.group(2)!;
      return '<img $attributes src="$href"';
    });
  }

  @Deprecated('use elementExtractor instead')
  List<String> paragraphExtractor(String htmlData) {
    final document = parse(htmlData);
    final paragraphElements = document.querySelectorAll('p');
    final paragraphList = <String>[];
    for (var para in paragraphElements) {
      paragraphList.add(para.outerHtml);
    }
    return paragraphList;
  }

  List<String> elementExtractor(String htmlData) {
    final document = parse(htmlData);
    final elements = document.body?.nodes ?? [];
    final effectiveElementList = <String>[];
    final tagsAllowed = [
      'p',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'div',
      'img',
      'svg',
      'image',
    ];
    for (var element in elements) {
      if (element is! Element) continue;
      if (!tagsAllowed.contains(element.localName)) continue;
      if (element.localName == 'div') {
        effectiveElementList.addAll(elementExtractor(element.innerHtml));
      } else if (element.localName == 'svg') {
        effectiveElementList.addAll(elementExtractor(element.innerHtml));
      } else {
        effectiveElementList.add(element.outerHtml);
      }
    }
    return effectiveElementList;
  }

  List<String> combineParagraph(List<String> paragraphList) {
    final combinedList = <String>[];
    var tempCombinedPara = '';
    for (var paragraph in paragraphList) {
      if (tempCombinedPara.length + paragraph.length > maxLength &&
          tempCombinedPara != '') {
        combinedList.add(tempCombinedPara);
        tempCombinedPara = '';
      }
      tempCombinedPara += paragraph;
    }
    combinedList.add(tempCombinedPara);
    return combinedList;
  }
}
