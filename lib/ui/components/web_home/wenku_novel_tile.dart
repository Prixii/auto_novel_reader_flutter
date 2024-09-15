import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_book_cover.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/wenku_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class WenkuNovelList extends StatelessWidget {
  const WenkuNovelList({
    super.key,
    required this.wenkuNovels,
    this.childAspectRatio = 1 / 1.5,
  });

  final List<WenkuNovelOutline> wenkuNovels;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1 / 1.5,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
          duration: const Duration(milliseconds: 375),
          position: index,
          columnCount: 3,
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: WenkuNovelTile(wenkuNovel: wenkuNovels[index]),
            ),
          ),
        ),
        itemCount: wenkuNovels.length,
      ),
    );
  }
}

class WenkuNovelTile extends StatelessWidget {
  const WenkuNovelTile({super.key, required this.wenkuNovel});
  final WenkuNovel wenkuNovel;
  @override
  Widget build(BuildContext context) {
    return wenkuNovel.map(
      wenkuNovelOutline: (novel) => _buildForWenkuNovelOutline(context, novel),
      wenkuNovelDto: (novel) => _buildForWenkuNovelDto(novel),
      wenkuVolumeDto: (novel) => _buildForWenkuVolumeDto(novel),
      amazonNovel: (novel) => _buildForAmazonNovel(novel),
      volumeJpDto: (novel) => _buildForVolumeJpDto(novel),
    );
  }

  Widget _buildForWenkuNovelOutline(
      BuildContext context, WenkuNovelOutline novel) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _toDetail(context, novel),
        radius: 8,
        child: Stack(
          children: [
            novel.cover == null
                ? PlainTextBookCover(title: novel.title)
                : CachedNetworkImage(
                    imageUrl: novel.cover!,
                    fit: BoxFit.cover,
                    errorWidget: (_, url, error) {
                      errorLogger.logError(error, StackTrace.current,
                          extra: 'url: $url');
                      return PlainTextBookCover(title: novel.title);
                    }),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildMicaTitle(novel, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicaTitle(WenkuNovelOutline novel, BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: const EdgeInsets.all(4),
        height: 46,
        width: double.infinity,
        color: styleManager.colorScheme(context).surface.withOpacity(0.8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Text(
            novel.titleZh,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: styleManager.titleSmall(context)?.copyWith(
                  color: styleManager.colorScheme(context).onPrimaryContainer,
                ),
          ),
        ),
      ),
    );
  }

  void _toDetail(BuildContext context, WenkuNovelOutline novel) async {
    readWenkuHomeBloc(context).add(WenkuHomeEvent.toWenkuDetail(novel.id));
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => WenkuNovelDetailContainer(novel.id)));
  }

  Widget _buildForWenkuNovelDto(WenkuNovelDto novel) {
    return const SizedBox.shrink();
  }

  Widget _buildForWenkuVolumeDto(WenkuVolumeDto novel) {
    return const SizedBox.shrink();
  }

  Widget _buildForAmazonNovel(AmazonNovel novel) {
    return const SizedBox.shrink();
  }

  Widget _buildForVolumeJpDto(VolumeJpDto novel) {
    return const SizedBox.shrink();
  }
}
