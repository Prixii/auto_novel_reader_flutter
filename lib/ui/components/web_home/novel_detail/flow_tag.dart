import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:flutter/material.dart';

class FlowTag extends StatelessWidget {
  const FlowTag({super.key, required this.attentions, required this.keywords});

  final List<String> attentions;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    return Wrap(runSpacing: 4.0, spacing: 6.0, children: [
      for (var tag in attentions)
        InfoBadge(
          tag,
          backgroundColor: styleManager.colorScheme.errorContainer,
          fontColor: styleManager.colorScheme.onErrorContainer,
        ),
      for (var tag in keywords)
        InfoBadge(
          tag,
          backgroundColor: styleManager.colorScheme.secondaryContainer,
          fontColor: styleManager.colorScheme.onSecondaryContainer,
        )
    ]);
  }
}
