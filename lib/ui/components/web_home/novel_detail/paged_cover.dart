import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_book_cover.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PagedCover extends StatefulWidget {
  const PagedCover({
    super.key,
    required this.urls,
  });

  final List<String> urls;

  @override
  State<PagedCover> createState() => _PagedCoverState();
}

class _PagedCoverState extends State<PagedCover> {
  var currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return widget.urls.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 328,
            child: Stack(
              children: [
                PageView.builder(
                  itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: widget.urls[index],
                    fit: BoxFit.fitHeight,
                    errorWidget: (_, __, ___) =>
                        const PlainTextBookCover(title: ' 暂无封面'),
                  ),
                  itemCount: widget.urls.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                ),
                InfoBadge(
                  '${currentPage + 1}/${widget.urls.length}',
                  copyOnLongPress: false,
                ),
              ],
            ),
          );
  }
}
