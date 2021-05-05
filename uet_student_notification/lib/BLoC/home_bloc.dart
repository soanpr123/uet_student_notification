import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class HomeBLoc extends Bloc{
  final _controller = StreamController<bool>();
  Stream<bool> get isLoggedIn => _controller.stream;

  void checkLoggedIn() async{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      bool isLoggedIn = sharedPreferences.getBool(Common.IS_LOGGED_IN) ?? false;
      _controller.sink.add(isLoggedIn);
  }

  @override
  void dispose() {
    _controller.close();
  }

  @override
  void init() {
    // TODO: implement init
  }
}