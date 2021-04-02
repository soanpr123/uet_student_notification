import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/UI/home_screen.dart';
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'BLoC/list_posts_bloc.dart';
import 'Common/common.dart';
import 'DataLayer/api_client.dart';
import 'UI/log_in_screen.dart';

void main() {
  runApp(MyApp());
}

Future<dynamic> BackgroundMessageHandler(Map<String, dynamic> message) {
  print(message);
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
  } else if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print("background  notification $notification");
  }
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  static final navigatorKey = new GlobalKey<NavigatorState>();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final bloc = ListPostsBloc();
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('paused state');
        break;
      case AppLifecycleState.resumed:
        SharedPreferences preferences = await SharedPreferences.getInstance();

        final aToken = preferences.getString(ACCESS_TOKEN);
        print(aToken);
        if(aToken!=""){
          bloc.checkToken(navigatorKey.currentContext, false);
        }

        print('paused resumed');

        break;

      case AppLifecycleState.inactive:
        print('inactive state');
        break;
      case AppLifecycleState.detached:
        print('detached state');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addObserver(this);
    });
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'UET Student Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
