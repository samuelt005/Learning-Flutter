// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_client/web_socket_client.dart';
// Add these new imports
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.name, required this.id})
      : super(key: key);

  final String name;
  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final socket = WebSocket(Uri.parse('ws://localhost:8765'));
  final List<types.Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late types.User otherUser;
  late types.User me;

  // Using ImgBB as the free storage service
  final String imgbbApiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();

    me = types.User(
      id: widget.id,
      firstName: widget.name,
    );

    socket.messages.listen((incomingMessage) async {
      if (incomingMessage.contains(' from ')) {
        List<String> parts = incomingMessage.split(' from ');
        String jsonString = parts[0];

        try {
          Map<String, dynamic> data = jsonDecode(jsonString);
          String id = data['id'];
          String msg = data['msg'];
          String nick = data['nick'] ?? id;
          String? fileName = data['fileName'];
          String? fileExtension = data['fileExtension'];
          String? fileType = data['fileType'];
          String? imageUrl = data['imageUrl'];

          if (id != me.id) {
            otherUser = types.User(
              id: id,
              firstName: nick,
            );

            if (fileType == 'image' && imageUrl != null) {
              // Handle received image URL
              _addImageMessage(otherUser, imageUrl, fileName ?? 'image.$fileExtension');
            } else if (fileName != null && fileExtension != null) {
              // Handle other file types
              await _handleFileReceived(msg, fileName, fileExtension);
            } else {
              // Handle text message
              onMessageReceived(msg);
            }
          }
        } catch (e) {
          print("Error parsing message: $e");
          print("Original message: $incomingMessage");
        }
      } else {
        print("Received message in unexpected format: $incomingMessage");
      }
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  // Helper method to add an image message
  void _addImageMessage(types.User author, String imageUrl, String name) {
    final imageMessage = types.ImageMessage(
      author: author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      name: name,
      size: 0, // We don't know the size from the URL
      uri: imageUrl,
    );
    _addMessage(imageMessage);
  }

  Future<void> _handleFileReceived(
      String base64Encoded, String fileName, String fileExtension) async {
    Uint8List fileBytes = base64Decode(base64Encoded);

    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/$fileName';

    File file = File(filePath);
    await file.writeAsBytes(fileBytes);

    var fileMessage = types.FileMessage(
      author: otherUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      name: fileName,
      size: fileBytes.length,
      uri: filePath,
    );
    _addMessage(fileMessage);
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

  // New method to upload image to ImgBB
  Future<String?> _uploadImageToImgBB(List<int> imageBytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      );

      String fileExtension = path.extension(fileName).replaceAll('.', '');

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', fileExtension),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['data']['url'];
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response: $responseData');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Alternative method using Firebase Storage (requires Firebase package)
  // Future<String?> _uploadImageToFirebase(List<int> imageBytes, String fileName) async {
  //   try {
  //     final storageRef = FirebaseStorage.instance.ref();
  //     final imageRef = storageRef.child('chat_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');
  //
  //     await imageRef.putData(Uint8List.fromList(imageBytes));
  //     return await imageRef.getDownloadURL();
  //   } catch (e) {
  //     print('Error uploading to Firebase: $e');
  //     return null;
  //   }
  // }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      String fileName = result.files.single.name;
      String fileExtension = fileName.split('.').last;

      List<int> fileBytes;
      // Get file bytes differently depending on platform
      if (kIsWeb) {
        fileBytes = result.files.single.bytes!;
      } else {
        File file = File(result.files.single.path!);
        fileBytes = await file.readAsBytes();
      }

      // Check if it's an image
      bool isImage =
          ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension.toLowerCase());

      if (isImage) {
        _sendImage(fileBytes, fileName, fileExtension);
      } else {
        String base64Encoded = base64Encode(fileBytes);
        _sendFileMessage(base64Encoded, fileName, fileExtension);
      }
    }
  }

  // Updated method to send images
  void _sendImage(List<int> imageBytes, String fileName, String fileExtension) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Upload the image to ImgBB and get the URL
      String? imageUrl = await _uploadImageToImgBB(imageBytes, fileName);

      // Close the loading dialog
      Navigator.pop(context);

      if (imageUrl != null) {
        // Create an image message with the URL
        final imageMessage = types.ImageMessage(
          author: me,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: randomString(),
          name: fileName,
          size: imageBytes.length,
          uri: imageUrl,
        );

        // Send the image URL through WebSocket
        var payload = {
          'id': me.id,
          'msg': 'Image shared',
          'nick': me.firstName,
          'fileName': fileName,
          'fileExtension': fileExtension,
          'fileType': 'image',
          'imageUrl': imageUrl,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        };

        socket.send(json.encode(payload));
        _addMessage(imageMessage);
      } else {
        // Show error if upload failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _sendFileMessage(
      String base64Encoded, String fileName, String fileExtension) {
    final fileMessage = types.TextMessage(
      author: me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: 'Arquivo: $fileName',
      metadata: {
        'fileName': fileName,
        'fileExtension': fileExtension,
        'base64': base64Encoded,
        'senderName': me.firstName,
      },
    );

    var payload = {
      'id': me.id,
      'msg': base64Encoded,
      'nick': me.firstName,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    socket.send(json.encode(payload));
    _addMessage(fileMessage);
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seu Chat: ${widget.name}',
            style: const TextStyle(
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
              onMessageTap: _handleMessageTap,
              // Customize the input by providing a custom builder
              customBottomWidget: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Attachment button (WhatsApp style)
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Colors.grey[600],
                      onPressed: () {
                        // Show attachment options bottom sheet
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        height: 56,
                                        width: 56,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.purple,
                                          size: 28,
                                        ),
                                      ),
                                      title: const Text('Photo'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        _pickFile();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Text input field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            _sendMessageCommon(text);
                            _messageController.clear();
                          }
                        },
                      ),
                    ),
                    // Send button
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.deepPurple,
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessageCommon(_messageController.text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
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
