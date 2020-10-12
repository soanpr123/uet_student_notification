import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class PostDetailsBloc extends Bloc {
  final _client = APIClient();
  final _controller = StreamController<Post>();
  final _titleController = StreamController<String>();

  Stream<Post> get post => _controller.stream;
  Stream<String> get title => _titleController.stream;

  void loadPostDetails(BuildContext context, int postId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    Post post = await _client.doGetPostDetails(context, postId, "$tokenType $aToken");
    if(post != null) {
      _titleController.sink.add(post.title);
    }
    _controller.sink.add(post);
  }

  @override
  void dispose() {
    _controller.close();
    _titleController.close();
  }
}
