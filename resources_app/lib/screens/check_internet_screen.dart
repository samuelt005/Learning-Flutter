import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class VerificarInternetScreen extends StatefulWidget {
  const VerificarInternetScreen({super.key});

  @override
  _VerificarInternetScreenState createState() =>
      _VerificarInternetScreenState();
}

class _VerificarInternetScreenState extends State<VerificarInternetScreen> {
  String _connectionStatus = 'Desconhecido';
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    var result = await _connectivity.checkConnectivity();
    setState(() {
      if (result.contains(ConnectivityResult.mobile)) {
        _connectionStatus = 'Conectado via dados móveis';
      } else if (result.contains(ConnectivityResult.wifi)) {
        _connectionStatus = 'Conectado via wi-fi';
      } else {
        _connectionStatus = 'Sem conexão ou conectado de outro modo';
      }
    });
  }

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
            Text(
              _connectionStatus,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkConnection();
              },
              child: const Text('Verificar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
