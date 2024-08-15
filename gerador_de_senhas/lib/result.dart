import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget result(password, context) {
  void copyResult() {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Senha copiada para a área de transferência')),
    );
  }

  return Container(
    height: 50,
    width: MediaQuery.of(context).size.width * .90,
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              password,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: copyResult,
        ),
      ],
    ),
  );
}
