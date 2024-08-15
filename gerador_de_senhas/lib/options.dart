import 'package:flutter/material.dart';

Widget options(
    uppercase,
    lowercase,
    numbers,
    specialCharacters,
    setUppercaseState,
    setLowercaseState,
    setNumbersState,
    setSpecialCharactersState) {
  return Center(
      child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(
          value: uppercase,
          onChanged: (bool? value) {
            setUppercaseState(value!);
          }),
      const Text('[A-Z]'),
      SizedBox(width: 30),
      Checkbox(
          value: lowercase,
          onChanged: (bool? value) {
            setLowercaseState(value!);
          }),
      const Text('[a-z]'),
      SizedBox(width: 30),
      Checkbox(
          value: numbers,
          onChanged: (bool? value) {
            setNumbersState(value!);
          }),
      const Text('[0-9]'),
      SizedBox(width: 30),
      Checkbox(
          value: specialCharacters,
          onChanged: (bool? value) {
            setSpecialCharactersState(value!);
          }),
      const Text('[@#!]')
    ],
  ));
}
