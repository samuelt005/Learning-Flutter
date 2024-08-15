import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gerador_de_senhas/button.dart';
import 'package:gerador_de_senhas/large_text.dart';
import 'package:gerador_de_senhas/options.dart';
import 'package:gerador_de_senhas/password_strength.dart';
import 'package:gerador_de_senhas/result.dart';
import 'package:gerador_de_senhas/sized_box.dart';
import 'package:gerador_de_senhas/sized_box_img.dart';
import 'package:gerador_de_senhas/slider.dart';
import 'package:gerador_de_senhas/small_text.dart';

void main() {
  runApp(const GeradorDeSenhasApp());
}

class GeradorDeSenhasAppState extends State<GeradorDeSenhasApp> {
  bool uppercase = true;
  bool lowercase = true;
  bool numbers = true;
  bool specialCharacters = true;
  double range = 6;
  String password = '';
  String passStrength = '';
  Color strengthColor = Colors.white;

  void setUppercaseState(uppercase) {
    setState(() {
      this.uppercase = uppercase;
    });
  }

  void setLowercaseState(lowercase) {
    setState(() {
      this.lowercase = lowercase;
    });
  }

  void setNumbersState(numbers) {
    setState(() {
      this.numbers = numbers;
    });
  }

  void setSpecialCharactersState(specialCharacters) {
    setState(() {
      this.specialCharacters = specialCharacters;
    });
  }

  void setRangeState(range) {
    setState(() {
      this.range = range;
    });
  }

  void generatePasswordState() {
    setState(() {
      password = generatePassword();
    });

    setPasswordStrength();
  }

  String generatePassword() {
    List<String> charList = <String>[
      lowercase ? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' : '',
      uppercase ? 'abcdefghijklmnopqrstuvwxyz' : '',
      numbers ? '0123456789' : '',
      specialCharacters ? '!@#\$%&*-=+,.<>;:/?' : ''
    ];

    final String chars = charList.join('');
    Random rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        range.round(), (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void setPasswordStrength() {
    int passwordStrengthInteger = 0;

    if (password.length < 8) {
      passStrength = 'Muito Fraca';
      strengthColor = Colors.red;
      return;
    }

    if (password.length <= 12) {
      passStrength = 'Fraca';
      strengthColor = Colors.orange;
      return;
    } else {
      passwordStrengthInteger++;
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      passwordStrengthInteger++;
    }

    if (password.contains(RegExp(r'[a-z]'))) {
      passwordStrengthInteger++;
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      passwordStrengthInteger++;
    }

    if (password.contains(RegExp(r'[!@#\$%&*-=+,.<>;:/?]'))) {
      passwordStrengthInteger++;
    }

    switch (passwordStrengthInteger) {
      case 3:
        passStrength = 'Fraca';
        strengthColor = Colors.orange;
        break;
      case 4:
        passStrength = 'Forte';
        strengthColor = Colors.lightGreen;
        break;
      case 5:
        passStrength = 'Muito Forte';
        strengthColor = Colors.green;
        break;
      default:
        passStrength = 'Muito Fraca';
        strengthColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gerador de senhas'),
          centerTitle: true,
          backgroundColor: Colors.black38,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 32),
        ),
        body: Column(
          children: [
            sizedBox(),
            sizedBoxImg(),
            largeText('Gere sua senha'),
            smallText('Escolha os parâmetros para gerar sua senha'),
            sizedBox(),
            Container(
              color: Colors.black26,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  options(
                      uppercase,
                      lowercase,
                      numbers,
                      specialCharacters,
                      setUppercaseState,
                      setLowercaseState,
                      setNumbersState,
                      setSpecialCharactersState),
                  slider(range, setRangeState),
                  button(generatePasswordState),
                ],
              ),
            ),
            sizedBox(),
            result(password, context),
            passwordStrength(passStrength, strengthColor)
          ],
        ),
        backgroundColor: Colors.white54,
      ),
    );
  }
}

class GeradorDeSenhasApp extends StatefulWidget {
  const GeradorDeSenhasApp({super.key});

  @override
  GeradorDeSenhasAppState createState() {
    return GeradorDeSenhasAppState();
  }
}
