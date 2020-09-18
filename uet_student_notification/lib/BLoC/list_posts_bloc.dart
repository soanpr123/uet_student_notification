import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class ListPostsBloc extends Bloc{

  final _controller = StreamController<List<Post>>();

  Stream<List<Post>> get listPosts => _controller.stream;

  void loadListPosts(){

  }

  @override
  void dispose() {
    _controller.close();
  }
}