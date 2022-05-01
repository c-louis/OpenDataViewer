import 'package:flutter/material.dart';

class LabeledSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final Widget label;

  const LabeledSwitch({Key? key, required this.value, required this.onChanged,
    required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        label,
        Switch(value: value, onChanged: onChanged)
      ],
    );
  }
}