import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Убедитесь, что Firebase инициализирован
  log("Обработка фоновое сообщение: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void setupNotificationChannels() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // ID канала
    'High Importance Notifications', // Название канала
    description:
        'This channel is used for important notifications.', // Описание
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  setupNotificationChannels(); // Настройка каналов уведомлений
  // Получение FCM токена
  String? token = await messaging.getToken();
  log("FCM Token: $token");
  // Регистрируем обработчик для фоновых сообщений
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Настройка обработчиков уведомлений
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Получено сообщение в режиме foreground: ${message.notification?.title}, ${message.notification?.body}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log('Приложение открыто через уведомление: ${message.notification?.title}, ${message.notification?.body}');
  });

  runApp(MyApp(token: token)); // Передача токена в MyApp
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token}); // Принимаем токен в конструкторе

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(token: token), // Передаем токен в MyHomePage
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String? token;

  const MyHomePage({super.key, this.token}); // Принимаем токен в конструкторе

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Push Notifications Test'),
      ),
      body: Center(
        child: token != null
            ? Text('FCM Token: $token')
            : CircularProgressIndicator(),
      ),
    );
  }
}
