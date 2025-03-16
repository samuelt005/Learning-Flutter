import 'package:flutter/material.dart';

class AcessarGpsScreen extends StatelessWidget {
  const AcessarGpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessar GPS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Localização não disponível',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Obter Localização Atual'),
            ),
          ],
        ),
      ),
    );
  }
}
