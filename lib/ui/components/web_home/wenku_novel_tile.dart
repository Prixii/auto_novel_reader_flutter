import 'dart:ui';

import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WenkuNovelTile extends StatelessWidget {
  const WenkuNovelTile({super.key, required this.wenkuNovel});
  final WenkuNovel wenkuNovel;
  @override
  Widget build(BuildContext context) {
    return wenkuNovel.map(
      wenkuNovelOutline: (novel) => _buildForWenkuNovelOutline(novel),
      wenkuNovelDto: (novel) => _buildForWenkuNovelDto(novel),
      wenkuVolumeDto: (novel) => _buildForWenkuVolumeDto(novel),
      amazonNovel: (novel) => _buildForAmazonNovel(novel),
      volumeJpDto: (novel) => _buildForVolumeJpDto(novel),
    );
  }

  Widget _buildForWenkuNovelOutline(WenkuNovelOutline novel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: novel.cover,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: Container(
                padding: const EdgeInsets.all(4),
                height: 46,
                width: double.infinity,
                color: Colors.black.withOpacity(0.4),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Text(
                      novel.titleZh,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: styleManager.titleSmall
                          ?.copyWith(color: styleManager.colorScheme.onPrimary),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
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
