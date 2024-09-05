import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class Selector extends StatefulWidget {
  const Selector(
      {super.key,
      required this.onTap,
      required this.tabs,
      this.tabController,
      this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 8)});
  final EdgeInsetsGeometry padding;
  final Function(String, int) onTap;
  final List<String> tabs;
  final TabController? tabController;

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: 0,
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
      child: _buildDropDownMenuButton(theme),
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
                          if (_tabController.length != widget.tabs.length) {
                            _updateTabController(tab);
                          }
                          final index = widget.tabs.indexOf(tab);
                          _tabController.index =
                              (index >= widget.tabs.length) ? 0 : index;
                          widget.onTap(tab, index);
                        });
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
                widget.tabs[_tabController.index],
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

  void _updateTabController(String tab) {
    final newTabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.tabs.indexOf(tab),
    );
    final oldTabController = _tabController;
    _tabController = newTabController;
    oldTabController.dispose();
  }
}
