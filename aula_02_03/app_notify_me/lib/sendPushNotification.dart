import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendPushNotificationScreen extends StatefulWidget {
  @override
  _SendPushNotificationScreenState createState() =>
      _SendPushNotificationScreenState();
}

class _SendPushNotificationScreenState
    extends State<SendPushNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _sendNotification() async {
    const String projectId = "xxxx"; // Substitua pelo seu Project ID
    const String fcmUrl =
        "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";
    const String accessToken = "xxxxxxxxx"; // Substitua pelo Access Token gerado

    String title = _titleController.text;
    String body = _bodyController.text;
    int delayInSeconds = int.tryParse(_timeController.text) ?? 0;

    Future.delayed(Duration(seconds: delayInSeconds), () async {
      try {
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        };

        var bodyData = jsonEncode({
          "message": {
            "topic": "all",
            "notification": {
              "title": title,
              "body": body,
            },
          },
        });

        var response =
            await http.post(Uri.parse(fcmUrl), headers: headers, body: bodyData);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notificação enviada com sucesso!")),
          );
          print("Resposta do FCM: ${response.body}");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao enviar notificação: ${response.body}")),
          );
          print("Erro: ${response.statusCode} | ${response.body}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar notificação: $e")),
        );
        print("Exceção: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enviar Notificação")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: "Mensagem"),
            ),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Atraso (segundos)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text("Enviar Notificação"),
            ),
          ],
        ),
      ),
    );
  }
}
