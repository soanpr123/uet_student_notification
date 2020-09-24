import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class ListPostsBloc extends Bloc{

  final _controller = StreamController<List<Post>>();

  Stream<List<Post>> get listPosts => _controller.stream;

  void loadListPosts() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    print("Access token: $aToken - $userId");
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