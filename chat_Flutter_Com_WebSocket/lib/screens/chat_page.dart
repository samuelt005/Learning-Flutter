import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:web_socket_client/web_socket_client.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.name, required this.id})
      : super(key: key);

  final String name;
  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final socket = WebSocket(Uri.parse('ws://localhost:8765/chat'));
  final List<types.Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late types.User otherUser;
  late types.User me;

  @override
  void initState() {
    super.initState();

    me = types.User(
      id: widget.id,
      firstName: widget.name,
    );

    socket.connection.listen((state) {
      print("WebSocket State: $state");

      if (state is Connected) {
        print("WebSocket conectado com sucesso!");
      } else if (state is Disconnected) {
        print("WebSocket desconectado!");
      } else if (state is Reconnecting) {
        print("Tentando reconectar...");
      }
    });

    socket.messages.listen((incomingMessage) {
      List<String> parts = incomingMessage.split(' from ');
      String jsonString = parts[0];

      Map<String, dynamic> data = jsonDecode(jsonString);
      String id = data['id'];
      String msg = data['msg'];
      String nick = data['nick'] ?? id;

      if (id != me.id) {
        otherUser = types.User(
          id: id,
          firstName: nick,
        );
        onMessageReceived(msg);
      }
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void onMessageReceived(String message) {
    var newMessage = types.TextMessage(
      author: otherUser,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      metadata: {
        'senderName': otherUser.firstName,
        'hora': DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
    _addMessage(newMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _sendMessageCommon(String text) {
    final textMessage = types.TextMessage(
      author: me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: text,
      metadata: {
        'senderName': me.firstName,
      },
    );

    var payload = {
      'id': me.id,
      'msg': text,
      'nick': me.firstName,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    socket.send(json.encode(payload));
    _addMessage(textMessage);
  }

  void _handleSendPressed(types.PartialText message) {
    _sendMessageCommon(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seu Chat: ${widget.name}',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              user: me,
              showUserAvatars: true,
              showUserNames: true,
              onSendPressed: _handleSendPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.close();
    super.dispose();
  }
}
