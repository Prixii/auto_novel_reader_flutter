import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class RadioFilter<T> extends StatefulWidget {
  const RadioFilter(
      {super.key,
      required this.title,
      required this.options,
      required this.values,
      required this.controller,
      this.initOptionName,
      this.initValue,
      this.onChanged});

  final List<String> options;
  final List<T> values;
  final String title;
  final RadioFilterController controller;
  final String? initOptionName;
  final T? initValue;
  final ValueChanged? onChanged;

  @override
  State<RadioFilter> createState() => _RadioFilterState<T>();
}

class _RadioFilterState<T> extends State<RadioFilter> {
  late String _selectedOption;
  late T _selectedValue;
  late final Color activeColor;
  final inactiveColor = Colors.white;

  @override
  void initState() {
    super.initState();
    activeColor = styleManager.colorScheme(context).secondary;
    _selectedOption = widget.initOptionName ?? widget.options.first;
    _selectedValue = widget.initValue ?? widget.values.first;
    widget.controller
        .setGetOptionsFunc(() => _selectedOption, () => _selectedValue);
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
                  _selectedOption = option;
                });
                final index = widget.options.indexOf(option);
                if (index != -1) widget.onChanged?.call(widget.values[index]);
                _selectedValue = widget.values[index];
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

class RadioFilterController<T> {
  RadioFilterController();

  String Function()? _getOptionNameFunc;
  T Function()? _getOptionValueFunc;

  void setGetOptionsFunc(String Function() nameFunc, T Function() valueFunc) {
    _getOptionNameFunc = nameFunc;
    _getOptionValueFunc = valueFunc;
  }

  String get optionName => _getOptionNameFunc!.call();
  T get optionValue => _getOptionValueFunc!.call();
}
