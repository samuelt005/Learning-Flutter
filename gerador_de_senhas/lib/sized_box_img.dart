import 'package:flutter/material.dart';

Widget sizedBoxImg() {
  return SizedBox(
    width: 200,
    height: 200,
    child: Image.network(
        "https://cdn.pixabay.com/photo/2013/04/01/09/02/read-only-98443_1280.png"),
  );
}
