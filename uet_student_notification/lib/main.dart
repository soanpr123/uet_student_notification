import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/UI/home_screen.dart';
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'BLoC/list_posts_bloc.dart';
import 'Common/common.dart';
import 'DataLayer/api_client.dart';
import 'UI/log_in_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  final bloc = ListPostsBloc();
bloc.loadListPosts(MyApp.navigatorKey.currentContext, false);
  await Firebase.initializeApp();
  print('Handling a background message ${bloc.unread.first.then((value) {
    print("value $value");
    FlutterAppBadger.updateBadgeCount(value);
  })}');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
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
