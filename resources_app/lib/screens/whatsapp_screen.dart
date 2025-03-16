import 'package:flutter/material.dart';

class EnviarMensagemWhatsappScreen extends StatelessWidget {
  const EnviarMensagemWhatsappScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Conexão com a Internet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Status da Conexão:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            const Text(
              'Conectado via Wi-Fi',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Verificar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
