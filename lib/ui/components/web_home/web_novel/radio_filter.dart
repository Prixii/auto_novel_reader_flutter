import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class RadioFilter<T> extends StatefulWidget {
  const RadioFilter(
      {super.key,
      required this.title,
      required this.options,
      required this.values,
      required this.controller,
      this.initValue,
      this.onChanged});

  final List<String> options;
  final List<T> values;
  final String title;
  final RadioFilterController controller;
  final String? initValue;
  final ValueChanged? onChanged;

  @override
  State<RadioFilter> createState() => _RadioFilterState();
}

class _RadioFilterState extends State<RadioFilter> {
  late String _selectedOption;
  final activeColor = styleManager.colorScheme.secondary;
  final inactiveColor = Colors.white;

  @override
  void initState() {
    _selectedOption = widget.options.first;
    widget.controller.setGetOptionsFunc(() => _selectedOption);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: styleManager.primaryColorTitleSmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: widget.options.map((option) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = option;
                });
                final index = widget.options.indexOf(option);
                if (index != -1) widget.onChanged?.call(widget.values[index]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      _selectedOption == option ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color:
                        _selectedOption == option ? inactiveColor : activeColor,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RadioFilterController {
  RadioFilterController();

  String Function()? _getOptionFunc;

  void setGetOptionsFunc(String Function() func) {
    _getOptionFunc = func;
  }

  String get value => _getOptionFunc!.call();
}
