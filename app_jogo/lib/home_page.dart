import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _imageApp = AssetImage("assets/images/hand_none.jpeg");
  var _message = "1,2,3 ... Já";
  var _userWins = 0;
  var _appWins = 0;
  var _draws = 0;

  void _selectedOption(String userChoice) {
    var options = ['rock', 'paper', 'scissors'];
    var appChoiceIndex = Random().nextInt(3);
    var appChoice = options[appChoiceIndex];

    // Update the app image based on the app's choice
    setState(() {
      _imageApp = AssetImage("assets/images/hand_$appChoice.jpeg");
    });

    if (appChoice == userChoice) {
      setState(() {
        _message = "Empate!";
        _draws++;
      });
    } else if ((userChoice == 'rock' && appChoice == 'scissors') ||
        (userChoice == 'paper' && appChoice == 'rock') ||
        (userChoice == 'scissors' && appChoice == 'paper')) {
      setState(() {
        _message = "Você venceu!";
        _userWins++;
      });
    } else {
      setState(() {
        _message = "Você perdeu!";
        _appWins++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo Jokenpô'),
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 32, bottom: 16),
            child: Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Image(
            image: _imageApp,
            height: 200,
          ),
          Padding(
            padding: EdgeInsets.only(top: 32, bottom: 16),
            child: Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _selectedOption('rock'),
                child: Image.asset(
                  'assets/images/hand_rock.jpeg',
                  height: 100,
                ),
              ),
              GestureDetector(
                onTap: () => _selectedOption('paper'),
                child: Image.asset(
                  'assets/images/hand_paper.jpeg',
                  height: 100,
                ),
              ),
              GestureDetector(
                onTap: () => _selectedOption('scissors'),
                child: Image.asset(
                  'assets/images/hand_scissors.jpeg',
                  height: 100,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Você: $_userWins',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'App: $_appWins',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Empate: $_draws',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
