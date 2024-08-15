import 'package:flutter/material.dart';

Widget slider(double range, void Function(double) setRangeState) {
  return SizedBox(
    width: 400,
    child: Slider(
      value: range,
      min: 4,
      max: 24,
      divisions: 50,
      label: range.round().toString(),
      onChanged: (double newRange) {
        setRangeState(newRange);
      },
    ),
  );
}
