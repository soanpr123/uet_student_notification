import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class ListPostsBloc extends Bloc{
  final _client = APIClient();
  List<Post> list = new List();
  final _controller = StreamController<List<Post>>();
  int currentPage = 0;

  Stream<List<Post>> get listPosts => _controller.stream;

  void loadListPosts(bool isLoadMore) async{
    if(isLoadMore){
      currentPage++;
    }else{
      list.clear();
      currentPage = 0;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
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

  Future<void> checkAndUpdateFcmToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final fcmToken = preferences.getString(Common.FCM_TOKEN);
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final isUpdateFcmToken = preferences.getBool(Common.IS_UPDATE_FCM_TOKEN) ?? false;
    if(!isUpdateFcmToken){
     final result = await _client.doUpdateToken(userId, "$tokenType $aToken",fcmToken);
     await preferences.setBool(Common.IS_UPDATE_FCM_TOKEN, result);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}