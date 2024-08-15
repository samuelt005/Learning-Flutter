import 'package:flutter/material.dart';

Widget passwordStrength(text, color) {
  return Text(
    text,
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color),
    textAlign: TextAlign.center,
  );
}
