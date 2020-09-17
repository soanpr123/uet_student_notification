import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/user.dart';

class LogInBloc extends Bloc{
  final _controller = StreamController<User>();
  Stream<User> get loggedInUser => _controller.stream;

  void doLogin(String username, String password){
    print("$username-$password");
  }

  @override
  void dispose() {
    _controller.close();
  }
}