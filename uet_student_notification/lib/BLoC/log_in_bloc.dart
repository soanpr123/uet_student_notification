import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/user.dart';

class LogInBloc extends Bloc {
  final _controller = StreamController<User>();
  final _showErrorController = StreamController<bool>();

  Stream<User> get loggedInUser => _controller.stream;
  Stream<bool> get isShowError => _showErrorController.stream;
  final _client = APIClient();

  void setShowError(bool isShowError){
    _showErrorController.sink.add(isShowError);
  }

  Future<bool> doLogin(String username, String password) async {
    final user = await _client.doLogin(username, password);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(Common.IS_LOGGED_IN, user != null);
    if (user != null) {
      await preferences.setInt(Common.USER_ID, user.id);
      await preferences.setString(Common.USER_NAME, user.username);
      await preferences.setString(Common.ACCESS_TOKEN, user.accessToken);
      await preferences.setString(Common.TOKEN_TYPE, user.tokenType);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _controller.close();
    _showErrorController.close();
  }
}
