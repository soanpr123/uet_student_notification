import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class ListPostsBloc extends Bloc{
  final _client = APIClient();
  List<Post> list = new List();
  final _controller = StreamController<List<Post>>();
  int currentPage = 1;
  static const PAGE_SIZE = 10;
  bool enableLoadMore = true;

  Stream<List<Post>> get listPosts => _controller.stream;

  Future<void> loadListPosts(BuildContext context, bool isLoadMore) async{
    if(isLoadMore){
      currentPage++;
    }else{
      list.clear();
      currentPage = 1;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final result = await _client.doGetListPosts(context, userId, currentPage, PAGE_SIZE, "$tokenType $aToken");
    if(result != null) {
      final listPosts = result.data;
      //dummy
      // DateFormat format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.sss'Z'");
      // Post post = Post(0);
      // post.title = "Title";
      // post.content = "Content";
      // post.createdDate = "2020-09-29T07:06:20.000000Z";
      // DateTime dateTime = format.parse(post.createdDate, true);
      // String formattedDate = DateFormat('kk:mm:ss EEE d-MM-yyyy').format(
      //     dateTime);
      // post.createdDate = formattedDate;
      // list.add(post);
      //
      if (result.pagination.currentPage == result.pagination.lastPage) {
        enableLoadMore = false;
      }
      list.addAll(listPosts);
      _controller.sink.add(list);
    }
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

  Future<void> updatePostStatus(BuildContext context, int postId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final result = await _client.doUpdatePostStatus(context, userId, postId, true, "$tokenType $aToken");
    for(Post post in list){
      if(post.id == postId){
        post.isRead = result;
      }
    }
    _controller.sink.add(list);
  }

  @override
  void dispose() {
    _controller.close();
  }
}