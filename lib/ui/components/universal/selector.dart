import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class Selector extends StatelessWidget {
  const Selector(
      {super.key,
      required this.onTap,
      required this.tabs,
      required this.value,
      this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 8)});

  final EdgeInsetsGeometry padding;
  final Function(int) onTap;
  final List<String> tabs;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: _buildDropDownMenuButton(theme, context),
    );
  }

  InkWell _buildDropDownMenuButton(ThemeData theme, BuildContext context) {
    return InkWell(
      onTap: () {
        final renderBox = context.findRenderObject() as RenderBox;
        var local = renderBox.localToGlobal(Offset.zero);
        var size = MediaQuery.of(context).size;
        showMenu(
            items: tabs
                .map((tab) => PopupMenuItem(
                      value: tab,
                      child: Text(tab),
                      onTap: () {
                        final index = tabs.indexOf(tab);
                        onTap(index);
                      },
                    ))
                .toList(),
            context: context,
            position: RelativeRect.fromLTRB(
              local.dx + 16,
              local.dy + renderBox.size.height,
              local.dx + renderBox.size.width,
              size.height,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(UniconsLine.angle_down),
          ],
        ),
      ),
    );
  }
}
