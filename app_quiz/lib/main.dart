import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Header da aplicação'),
        ),
        body: Center(
            child: Container(
          height: 200,
          width: 200,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    print('Teste 1');
                  },
                  child: const Text('Botão 1')),
              const Text('Item 2'),
              const Text('Item 3'),
              const Text('Item 4'),
            ],
          ),
        )),
      ),
    );
  }
}
