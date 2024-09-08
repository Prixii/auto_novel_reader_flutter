import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class CheckFilter<T> extends StatefulWidget {
  const CheckFilter(
      {super.key,
      required this.title,
      required this.options,
      required this.optionsValue,
      required this.controller,
      this.initValue});
  final String title;
  final List<String> options;
  final List<T> optionsValue;
  final List<String>? initValue;
  final CheckFilterController controller;

  @override
  State<CheckFilter> createState() => _CheckFilterState<T>();
}

class _CheckFilterState<T> extends State<CheckFilter> {
  final Map<String, bool> _selectedOptions = {};
  final Map<T, bool> _selectedValues = {};
  late final Color activeColor;
  final inactiveColor = Colors.white;
  @override
  void initState() {
    super.initState();
    activeColor = styleManager.colorScheme(context).secondary;
    widget.controller.setGetOptionsFunc(() {
      var list = <T>[];
      for (var entry in _selectedValues.entries) {
        if (entry.value) {
          list.add(entry.key);
        }
      }
      return list;
    });

    for (var i = 0; i < widget.options.length; i++) {
      final option = widget.options[i];
      _selectedOptions[option] = widget.initValue?.contains(option) ?? true;
      _selectedValues[widget.optionsValue[i]] =
          widget.initValue?.contains(option) ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: styleManager.primaryColorTitleSmall(context),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: widget.options.map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  // 切换选项的选中状态
                  _selectedOptions[option] = !_selectedOptions[option]!;
                  final index = widget.options.indexOf(option);
                  _selectedValues[widget.optionsValue[index]] =
                      _selectedOptions[option]!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      _selectedOptions[option]! ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color:
                        _selectedOptions[option]! ? inactiveColor : activeColor,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class CheckFilterController<T> {
  CheckFilterController();

  List<T> Function()? getOptionsFunc;

  void setGetOptionsFunc(List<T> Function() func) {
    getOptionsFunc = func;
  }

  List<T> get values => getOptionsFunc?.call() ?? [];
}
