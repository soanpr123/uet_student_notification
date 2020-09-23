import 'dart:async';

import 'package:intl/intl.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class ListPostsBloc extends Bloc{

  final _controller = StreamController<List<Post>>();

  Stream<List<Post>> get listPosts => _controller.stream;

  void loadListPosts() async{
    List<Post> list = new List();
    //dummy data
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss EEE d-MM-yyyy').format(now);
    Post test;
    for(int i = 0; i < 10; i++){
      test = new Post(i);
      test.title = "Title $i";
      test.content = "Content $i";
      test.date = formattedDate;
      list.add(test);
    }
    await Future.delayed(Duration(seconds: 2));
    _controller.sink.add(list);
  }

  @override
  void dispose() {
    _controller.close();
  }
}