const htmlUtil = _HtmlUtil();

class _HtmlUtil {
  String redirectSource(String html, String url) {
    return html
        .replaceAll('src="', 'src="file://$url/')
        .replaceAll('href="', 'href="file://$url/')
        .replaceAll('../', '');
  }

  String removeHeadSection(String html) {
    int startIndex = html.indexOf('<head>');
    if (startIndex == -1) return html;

    int endIndex = html.indexOf('</head>') + '</head>'.length;
    if (endIndex == -1) return html;

    return html.substring(0, startIndex) + html.substring(endIndex);
  }

  const _HtmlUtil();
}
