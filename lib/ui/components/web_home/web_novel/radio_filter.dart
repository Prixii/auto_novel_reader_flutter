import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class RadioFilter extends StatefulWidget {
  const RadioFilter(
      {super.key,
      required this.title,
      required this.options,
      required this.controller,
      this.initValue});

  final List<String> options;
  final String title;
  final RadioFilterController controller;
  final String? initValue;

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
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                width: 100,
                decoration: BoxDecoration(
                  color:
                      _selectedOption == option ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: _selectedOption == option
                          ? inactiveColor
                          : activeColor,
                      fontSize: 13,
                    ),
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
