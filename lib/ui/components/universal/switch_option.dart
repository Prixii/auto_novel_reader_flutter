import 'package:flutter/material.dart';

class SwitchOption extends StatefulWidget {
  const SwitchOption(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.icon});
  final IconData? icon;
  final bool value;
  final String label;
  final Function(bool) onChanged;

  @override
  State<SwitchOption> createState() => _SwitchOptionState();
}

class _SwitchOptionState extends State<SwitchOption> {
  late bool value;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          (widget.icon == null)
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    widget.icon,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
          Expanded(
              child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyLarge,
          )),
          Switch(
              value: value,
              onChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
                widget.onChanged.call(newValue);
              }),
        ],
      ),
    );
  }
}
