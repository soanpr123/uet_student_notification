import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/common.dart' as Common;

class HomeBLoc extends Bloc{
  final _controller = StreamController<bool>();
  Stream<bool> get isLoggedIn => _controller.stream;

  void checkLoggedIn() async{

  }

  @override
  void dispose() {
    _controller.close();
  }
}