import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'sendPushNotification.dart';
import 'sendRealDataBase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCbaRUBMmbBa7Bt1GMS0Za0VS6AxfNeOiQ",
      appId: "1:313432554152:android:9c91e82b56bf096140209d",
      messagingSenderId: "313432554152",
      projectId: "samuel-biopark",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setupFirebaseMessagingListener();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('Permissões concedidas: ${settings.authorizationStatus}');
  }

  void _setupFirebaseMessagingListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Notificação recebida: ${message.notification?.title}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notificação: ${message.notification?.body}")),
        );
      }
    });
  }

  void _openRemoteNotificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendPushNotificationScreen()),
    );
  }

    void _openRealTimeDatabaseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendRealDataBaseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Notifications')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.send),
              title: Text('Envia Push'),
              onTap: () {
                Navigator.pop(context);
                _openRemoteNotificationScreen();
              },
            ),
                        ListTile(
              leading: Icon(Icons.send),
              title: Text('Envia e retorna dados RealtimeDataBase'),
              onTap: () {
                Navigator.pop(context);
                _openRealTimeDatabaseScreen();
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('Aguardando notificações...')),
    );
  }
}
