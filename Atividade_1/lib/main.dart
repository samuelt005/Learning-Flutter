import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

void main() {
  runApp(PasswordGeneratorApp());
}

class PasswordGeneratorApp extends StatelessWidget {
  const PasswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  _PasswordGeneratorScreenState createState() {
    return _PasswordGeneratorScreenState();
  }
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  Database? _database;
  List<String> _passwords = [];

  int length = 12;
  int letters = 6;
  int numbers = 3;
  int specials = 3;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'passwords.db'),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE passwords(id INTEGER PRIMARY KEY, password TEXT)');
      },
      version: 1,
    );
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final List<Map<String, dynamic>> maps = await _database!.query('passwords');
    setState(() {
      _passwords = List.generate(maps.length, (i) => maps[i]['password']);
    });
  }

  String _generatePassword() {
    const lettersChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbersChars = "0123456789";
    const specialChars = "!@#\$%^&*()_+";

    String allChars = (letters > 0 ? lettersChars : '') +
        (numbers > 0 ? numbersChars : '') +
        (specials > 0 ? specialChars : '');

    if (allChars.isEmpty) return '';

    List<String> password = [];
    Random rnd = Random();

    password.addAll(List.generate(letters, (index) => lettersChars[rnd.nextInt(lettersChars.length)]));
    password.addAll(List.generate(numbers, (index) => numbersChars[rnd.nextInt(numbersChars.length)]));
    password.addAll(List.generate(specials, (index) => specialChars[rnd.nextInt(specialChars.length)]));

    password.shuffle();

    return password.join();
  }

  Future<void> _savePassword() async {
    String newPassword = _generatePassword();
    if (newPassword.isEmpty) return;

    await _database!.insert(
      'passwords',
      {'password': newPassword},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerador de Senhas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Comprimento da Senha: $length'),
                Slider(
                  min: 6,
                  max: 20,
                  value: length.toDouble(),
                  onChanged: (value) => setState(() => length = value.toInt()),
                ),
                Text('Letras: $letters'),
                Slider(
                  min: 0,
                  max: length.toDouble(),
                  value: letters.toDouble(),
                  onChanged: (value) => setState(() => letters = value.toInt()),
                ),
                Text('Números: $numbers'),
                Slider(
                  min: 0,
                  max: length.toDouble(),
                  value: numbers.toDouble(),
                  onChanged: (value) => setState(() => numbers = value.toInt()),
                ),
                Text('Especiais: $specials'),
                Slider(
                  min: 0,
                  max: length.toDouble(),
                  value: specials.toDouble(),
                  onChanged: (value) => setState(() => specials = value.toInt()),
                ),
                ElevatedButton(
                  onPressed: _savePassword,
                  child: Text('Gerar e Salvar Senha'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _passwords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_passwords[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
