import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class PostDetails extends Bloc{

  final _controller = StreamController<Post>();
  Stream<Post> get post => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}