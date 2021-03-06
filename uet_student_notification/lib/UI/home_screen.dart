import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/home_bloc.dart';
import 'package:uet_student_notification/BLoC/log_in_bloc.dart';
import 'package:uet_student_notification/Common/loading_overlay.dart';
import 'package:uet_student_notification/UI/list_posts_screen.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

LoadingOverlay loadingOverlay;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadingOverlay = LoadingOverlay.of(context);
    final storage = new FlutterSecureStorage();
    final bloc = HomeBLoc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.checkLoggedIn();
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
