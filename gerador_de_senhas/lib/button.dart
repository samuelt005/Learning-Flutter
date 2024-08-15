import 'package:flutter/material.dart';

Widget button(generatePasswordState) {
  return Container(
    height: 40,
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: ElevatedButton(
      onPressed: generatePasswordState,
      child: const Text('Gerar senha'),
    ),
  );
}
