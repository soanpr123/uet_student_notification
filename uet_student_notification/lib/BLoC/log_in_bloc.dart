import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/user.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class LogInBloc extends Bloc{
  final _controller = StreamController<User>();
  Stream<User> get loggedInUser => _controller.stream;
  final _client = APIClient();

  Future<bool> doLogin(String username, String password) async{
    _client.doLogin(username, password);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(Common.IS_LOGGED_IN, true);
    return  Future.delayed(Duration(seconds: 10), () => true);
  }

  @override
  void dispose() {
    _controller.close();
  }
}