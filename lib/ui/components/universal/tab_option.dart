import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class TabOption extends StatefulWidget {
  const TabOption(
      {super.key,
      required this.initValue,
      required this.label,
      required this.onTap,
      required this.tabs,
      this.tip,
      this.padding = const EdgeInsets.fromLTRB(20, 8, 32, 8),
      this.icon,
      this.width});
  final IconData? icon;
  final String label;
  final EdgeInsetsGeometry padding;
  final Function(String, int) onTap;
  final int initValue;
  final List<String> tabs;
  final double? width;
  final String? tip;

  @override
  State<TabOption> createState() => _TabOptionState();
}

class _TabOptionState extends State<TabOption> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initValue,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              (widget.icon == null)
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(widget.icon),
                    ),
              Text(
                widget.label,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
              ),
              Expanded(child: Container()),
              _buildDropDownMenuButton(theme, widget.width),
            ],
          ),
          if (widget.tip != null)
            Text(widget.tip!, style: styleManager.tipText),
        ],
      ),
    );
  }

  InkWell _buildDropDownMenuButton(ThemeData theme, double? width) {
    return InkWell(
      onTap: () {
        final renderBox = context.findRenderObject() as RenderBox;
        var local = renderBox.localToGlobal(Offset.zero);
        var size = MediaQuery.of(context).size;
        showMenu(
            items: widget.tabs
                .map((tab) => PopupMenuItem(
                      value: tab,
                      child: Text(tab),
                      onTap: () {
                        setState(() {
                          final index = widget.tabs.indexOf(tab);
                          _tabController.index = index;
                          widget.onTap(tab, index);
                        });
                      },
                    ))
                .toList(),
            context: context,
            position: RelativeRect.fromLTRB(
              local.dx + renderBox.size.width - 140,
              local.dy + 8,
              local.dx + renderBox.size.width,
              size.height,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        width: (width ?? 100),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.tabs[_tabController.index],
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
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
