import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class RadioFilter<T> extends StatelessWidget {
  const RadioFilter(
      {super.key,
      required this.title,
      required this.options,
      required this.values,
      required this.selectedOption,
      required this.onChanged});

  final List<String> options;
  final List<T> values;
  final String title;
  final ValueChanged<int> onChanged;
  final String selectedOption;

  @override
  Widget build(BuildContext context) {
    final activeColor = styleManager.colorScheme(context).secondary;
    const inactiveColor = Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: styleManager.primaryColorTitleSmall(context),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: options.map((option) {
            return GestureDetector(
              onTap: () {
                final index = options.indexOf(option);
                if (index != -1) onChanged.call(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: selectedOption == option ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color:
                        selectedOption == option ? inactiveColor : activeColor,
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
