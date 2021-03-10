import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uet_student_notification/UI/home_screen.dart';

void main() {

  runApp(MyApp());

}
Future<dynamic> BackgroundMessageHandler(Map<String, dynamic> message) {
  print(message);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
  }else if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print("background  notification $notification");
  }

}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'UET Student Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }

}
