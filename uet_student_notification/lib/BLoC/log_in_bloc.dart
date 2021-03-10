import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/user.dart';

class LogInBloc extends Bloc {
  final _storage = FlutterSecureStorage();
  final _controller = StreamController<User>();
  final _showErrorController = StreamController<bool>();

  final _controllerUsername = StreamController<String>();
  final _controllerPass = StreamController<String>();

  Stream<User> get loggedInUser => _controller.stream;
  Stream<bool> get isShowError => _showErrorController.stream;
  Stream get streamUsername => _controllerUsername.stream;
  Stream get streamPass => _controllerPass.stream;
  final _client = APIClient();

  void setShowError(bool isShowError) {
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
      await preferences.setString(Common.PASS, password);
      await _storage.write(key: Common.PASS, value: password);
      return true;
    }
    return false;
  }

  addDataStream() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String email = preferences.getString(Common.USER_NAME);
    await _storage.read(key: Common.PASS).then((value) {
      if (email != null && value != null) {
        _controllerUsername.sink.add(email);
        _controllerPass.sink.add(value);
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    _showErrorController.close();
    _controllerUsername.close();
    _controllerPass.close();
  }
}
