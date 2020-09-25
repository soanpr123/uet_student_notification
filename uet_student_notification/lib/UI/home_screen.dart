import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/home_bloc.dart';
import 'package:uet_student_notification/UI/list_posts_screen.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  Widget build(BuildContext context) {
    final bloc = HomeBLoc();
    WidgetsBinding.instance.addPostFrameCallback((_){
      bloc.checkLoggedIn();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("UET onMessage: $message");
          // _showItemDialog(message);
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("UET onLaunch: $message");
          // _navigateToItemDetail(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("UET onResume: $message");
          // _navigateToItemDetail(message);
        },
      );
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      _firebaseMessaging.getToken().then((String token) {
        assert(token != null);
        print("FCM Token: $token");
        bloc.saveFcmToken(token);
      });
    });

    return BlocProvider<HomeBLoc>(
      bloc: bloc,
      child: StreamBuilder<bool>(
        stream: bloc.isLoggedIn,
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data;
          if (isLoggedIn == null) {
            return _buildWelcome();
          }

          if (isLoggedIn) {
            return ListPostsScreen();
          }

          return LogInScreen();
        },
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        color: Colors.white);
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
  }

  /*
  * {notification: {title: Test ne, body: Test xem sao}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  * */

}
