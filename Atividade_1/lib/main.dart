import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: PasswordGeneratorApp()));
}

class PasswordGeneratorApp extends StatefulWidget {
  const PasswordGeneratorApp({super.key});

  @override
  _PasswordGeneratorAppState createState() => _PasswordGeneratorAppState();
}

class _PasswordGeneratorAppState extends State<PasswordGeneratorApp> {
  final List<String> _generatedPasswords = [];

  int _length = 12;
  int _letters = 4;
  int _numbers = 4;
  int _specialChars = 4;

  final _lettersSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final _numbersSet = '0123456789';
  final _specialCharsSet = '!@#\$%^&*()_+{}|<>?~';

  String _generatePassword() {
    final random = Random();

    String password = '';

    password +=
        List.generate(
          _letters,
          (index) => _lettersSet[random.nextInt(_lettersSet.length)],
        ).join();
    password +=
        List.generate(
          _numbers,
          (index) => _numbersSet[random.nextInt(_numbersSet.length)],
        ).join();
    password +=
        List.generate(
          _specialChars,
          (index) => _specialCharsSet[random.nextInt(_specialCharsSet.length)],
        ).join();

    return String.fromCharCodes(password.runes.toList()..shuffle(random));
  }

  void _addPassword() {
    final password = _generatePassword();
    setState(() {
      _generatedPasswords.add(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gerador de Senhas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(
              "Comprimento",
              _length,
              8,
              32,
              (value) => setState(() => _length = value.toInt()),
            ),
            _buildSlider(
              "Letras",
              _letters,
              0,
              _length,
              (value) => setState(() => _letters = value.toInt()),
            ),
            _buildSlider(
              "Números",
              _numbers,
              0,
              _length,
              (value) => setState(() => _numbers = value.toInt()),
            ),
            _buildSlider(
              "Caracteres Especiais",
              _specialChars,
              0,
              _length,
              (value) => setState(() => _specialChars = value.toInt()),
            ),
            ElevatedButton(onPressed: _addPassword, child: Text("Gerar Senha")),
            Expanded(
              child: ListView.builder(
                itemCount: _generatedPasswords.length,
                itemBuilder:
                    (context, index) => ListTile(
                      title: Text(
                        _generatedPasswords[index],
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value"),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
