import 'package:flutter/material.dart';
import 'package:uet_student_notification/UI/home_screen.dart';


void main() {
  runApp(MyApp());
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
