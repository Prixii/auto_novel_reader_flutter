import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class TabOption extends StatefulWidget {
  const TabOption(
      {super.key,
      required this.initValue,
      required this.label,
      required this.onTap,
      required this.tabs,
      this.padding = const EdgeInsets.fromLTRB(32, 8, 32, 8),
      this.icon});
  final IconData? icon;
  final String label;
  final EdgeInsetsGeometry padding;
  final Function(String, int) onTap;
  final int initValue;
  final List<String> tabs;

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
      child: Row(
        children: [
          (widget.icon == null)
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(widget.icon),
                ),
          Expanded(
              child: Text(
            widget.label,
            style: theme.textTheme.bodyLarge,
            maxLines: 1,
          )),
          _buildDropDownMenuButton(theme),
        ],
      ),
    );
  }

  InkWell _buildDropDownMenuButton(ThemeData theme) {
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
            position: RelativeRect.fromLTRB(local.dx + size.width - 110,
                local.dy, local.dx + size.width - 20, size.height + local.dy));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        width: 100,
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
              ),
            ),
            const Icon(UniconsLine.angle_down),
          ],
        ),
      ),
    );
  }
}
