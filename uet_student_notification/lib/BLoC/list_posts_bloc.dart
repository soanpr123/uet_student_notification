import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class ListPostsScreen extends Bloc{

  final _controller = StreamController<List<Post>>();

  Stream<List<Post>> get listPosts => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}