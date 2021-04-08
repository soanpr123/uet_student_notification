import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/DataLayer/api_client.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';
import 'package:uet_student_notification/main.dart';

class ListPostsBloc extends Bloc {
  final _client = APIClient();
  List<Post> list = new List();
  int currentPage = 1;
  static const PAGE_SIZE = 10;
  bool enableLoadMore = true;
  final _controller = StreamController<List<Post>>();
  final _usernameController = StreamController<String>();
  final _unreadController = StreamController<int>();
  Stream<List<Post>> get listPosts => _controller.stream;
  Stream<String> get username => _usernameController.stream;
  Stream<int> get unread => _unreadController.stream;
  int unreadPosts = 0;

  void loadUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final username = preferences.getString(Common.USER_NAME);
    _usernameController.sink.add(username);
  }

  void logOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(Common.USER_ID, 0);
    await preferences.setString(Common.ACCESS_TOKEN, "");
    await preferences.setString(Common.TOKEN_TYPE, "");
    await preferences.setBool(Common.IS_LOGGED_IN, false);
    await preferences.setBool(Common.IS_UPDATE_FCM_TOKEN, false);
    context.replaceAllWith(LogInScreen());
  }

  Future<void> checkToken(BuildContext context, bool isLoadMore) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final result = await _client.doGetListPosts(
        context, userId, currentPage, PAGE_SIZE, "$tokenType $aToken");
    print("result la1 $result");
    if (result != null) {}
  }

  Future<void> loadListPosts(BuildContext context, bool isLoadMore) async {
    if (isLoadMore) {
      currentPage++;
    } else {
      list.clear();
      currentPage = 1;
      _controller.sink.add(null);
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final result = await _client.doGetListPosts(
        context, userId, currentPage, PAGE_SIZE, "$tokenType $aToken");

    if (result != null) {
      final listPosts = result.data;

      enableLoadMore =
          result.pagination.currentPage != result.pagination.lastPage;
      list.addAll(listPosts);
      _controller.sink.add(list);
      unreadPosts = result.pagination.total - result.pagination.countRead;
      _unreadController.sink.add(unreadPosts);
    }
  }

  void saveFcmToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Common.FCM_TOKEN, token);
  }

  Future<void> checkAndUpdateFcmToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final fcmToken = preferences.getString(Common.FCM_TOKEN);
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final isUpdateFcmToken =
        preferences.getBool(Common.IS_UPDATE_FCM_TOKEN) ?? false;
    if (!isUpdateFcmToken) {
      final result =
          await _client.doUpdateToken(userId, "$tokenType $aToken", fcmToken);
      await preferences.setBool(Common.IS_UPDATE_FCM_TOKEN, result);
    }
  }

  Future<void> updatePostStatus(BuildContext context, int postId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final tokenType = preferences.getString(Common.TOKEN_TYPE);
    final aToken = preferences.getString(Common.ACCESS_TOKEN);
    final userId = preferences.getInt(Common.USER_ID);
    final result = await _client.doUpdatePostStatus(
        context, userId, postId, true, "$tokenType $aToken");
    for (Post post in list) {
      if (post.id == postId) {
        post.isRead = result;
      }
    }
    if (result) {
      unreadPosts--;
      _unreadController.sink.add(unreadPosts);
    }
    _controller.sink.add(list);
  }

  @override
  void dispose() {
    _usernameController.close();
    _controller.close();
    _unreadController.close();
  }

  @override
  void init() {
    // TODO: implement init
  }
}
