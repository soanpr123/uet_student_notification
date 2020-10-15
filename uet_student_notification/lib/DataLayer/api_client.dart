import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/DataLayer/page_post.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/DataLayer/user.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;

class APIClient {
  final _baseUrl = "thongbao.uet.vnu.edu.vn";
  final _contextRoot = 'api';
  final _login = "auth/ldap/login";
  final _updateFCMToken = "v1/update-firebase-token";
  final _userPosts = "v1/user-posts";
  final _postDetails = "v1/user-post";
  final _updatePostStatus = "v1/update-status";

  void clearUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<User> doLogin(String username, String password) async {
    final result = await postRequest(
        path: _login, body: {'username': username, 'password': password});
    if (result != null) {
      try {
        final user = User.fromJson(result['user_data']);
        user.accessToken = result['access_token'];
        user.tokenType = result['token_type'];
        user.expireDate = result['expires_at'];
        return user;
      } on Exception catch (e) {
        print(e);
      }
    }
    return null;
  }

  Future<bool> doUpdateToken(
      int userId, String accessToken, String fcmToken) async {
    final result = await postRequestWithToken(null,
        path: _updateFCMToken,
        body: {"user_id": userId, "firebase_token": fcmToken},
        accessToken: accessToken);
    if (result != null) {
      final isSuccess = result["status"] == "true";
      final message = result["message"];
      print(message);
      return isSuccess;
    }
    return false;
  }

  Future<PagePost> doGetListPosts(BuildContext context, int userId, int page,
      int pageSize, String accessToken) async {
    final result = await getRequestWithToken(context,
        path: _userPosts,
        parameters: {
          "user_id": userId.toString(),
          "page": page.toString(),
          "page_size": pageSize.toString()
        },
        accessToken: accessToken);
    if (result != null) {
      return PagePost.fromJson(result);
    }
    return null;
  }

  Future<Post> doGetPostDetails(
      BuildContext context, int postId, String accessToken) async {
    final result = await getRequestWithToken(context,
        path: "$_postDetails/$postId", accessToken: accessToken);
    if (result != null) {
      return Post.fromJson(result);
    }
    return null;
  }

  Future<bool> doUpdatePostStatus(BuildContext context, int userId, int postId,
      bool isRead, String accessToken) async {
    final result = await postRequestWithToken(context,
        path: _updatePostStatus,
        body: {
          "user_id": userId,
          "posts": [
            {"post_id": postId, "is_read": true}
          ]
        },
        accessToken: accessToken);
    if (result != null) {
      final bool isSuccess = result["status"] == "true";
      final message = result["message"];
      final postIds = result["data"];
      print(message);
      return isSuccess && postIds.isEmpty;
    }
    return false;
  }

  Future<Map> postRequest(
      {@required String path, Map<String, dynamic> body}) async {
    final uri = Uri.https(_baseUrl, '$_contextRoot/$path');
    final results = await http
        .post(uri, headers: _headers, body: json.encode(body))
        .catchError((Object error) {
      print(error);
      return null;
    });
    if (results != null) {
      switch (results.statusCode) {
        case 200:
          final jsonObject = json.decode(results.body);
          return jsonObject;
          break;
      }
    }
    return null;
  }

  Future<Map> getRequest(
      {@required String path, Map<String, String> parameters}) async {
    final uri = Uri.https(_baseUrl, '$_contextRoot/$path', parameters);
    final results =
        await http.get(uri, headers: _headers).catchError((Object error) {
      print(error);
      return null;
    });
    if (results != null) {
      switch (results.statusCode) {
        case 200:
          final jsonObject = json.decode(results.body);
          return jsonObject;
          break;
      }
    }
    return null;
  }

  Future<Map> postRequestWithToken(BuildContext context,
      {@required String path,
      Map<String, dynamic> body,
      String accessToken}) async {
    final uri = Uri.https(_baseUrl, '$_contextRoot/$path');
    final results = await http
        .post(uri,
            headers: _headersWithToken(accessToken), body: json.encode(body))
        .catchError((Object error) {
      print(error);
      return null;
    });
    if (results != null) {
      switch (results.statusCode) {
        case 200:
          final jsonObject = json.decode(results.body);
          return jsonObject;
          break;
        case 401:
          if (context != null) {
            clearUser();
            context.replaceAllWith(LogInScreen());
            Common.showToast("Session is expired");
          }
          break;
      }
    }
    return null;
  }

  Future<Map> getRequestWithToken(BuildContext context,
      {@required String path,
      Map<String, String> parameters,
      String accessToken}) async {
    final uri = Uri.https(_baseUrl, '$_contextRoot/$path', parameters);
    final results = await http
        .get(uri, headers: _headersWithToken(accessToken))
        .catchError((Object error) {
      print(error);
      return null;
    });
    if (results != null) {
      switch (results.statusCode) {
        case 200:
          final jsonObject = json.decode(results.body);
          return jsonObject;
          break;
        case 401:
          if (context != null) {
            clearUser();
            context.replaceAllWith(LogInScreen());
            Common.showToast("Session is expired");
          }
          break;
      }
    }
    return null;
  }

  Map<String, String> get _headers =>
      {'Accept': 'application/json', 'Content-type': 'application/json'};

  Map<String, String> _headersWithToken(String token) => {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Authorization': token
      };
}
