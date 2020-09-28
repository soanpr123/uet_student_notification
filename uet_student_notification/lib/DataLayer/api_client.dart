import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/DataLayer/user.dart';

class APIClient {
  final _baseUrl = "112.137.129.31";
  final _contextRoot = 'api';
  final _login = "auth/login";
  final _updateFCMToken = "v1/update-firebase-token";
  final _userPosts = "v1/user-posts";

  Future<User> doLogin(String username, String password) async {
    final result = await postRequest(
        path: _login, body: {'username': username, 'password': password});
    if (result != null) {
      final user = User.fromJson(result['user_data']);
      user.accessToken = result['access_token'];
      user.tokenType = result['token_type'];
      user.expireDate = result['expires_at'];
      return user;
    }
    return null;
  }

  Future<bool> doUpdateToken(int userId, String accessToken,
      String fcmToken) async {
    final result = await postRequestWithToken(
        path: _updateFCMToken,
        body: {"user_id": userId, "firebase_token": fcmToken},
        accessToken: accessToken);
    if (result != null) {
      final bool isSuccess = result["status"] == "true";
      final String message = result["message"];
      print(message);
      return isSuccess;
    }
    return false;
  }

  Future<List<Post>> doGetListPosts(int userId, int page, int pageSize,
      String accessToken) async {
    final result = await getRequestWithToken(
        path: _userPosts,
        parameters: {
          "user_id": userId.toString(),
          "page": page.toString(),
          "page_size": pageSize.toString()
        },
        accessToken: accessToken);
    if (result != null) {
      final pagination = result['pagination'];
      final total = pagination['total'];
      final data = result['data'];
      DateFormat format = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
      return data
          .map<Post>((json) {
        final post = Post.fromJson(json);
        DateTime dateTime = format.parse(post.createdDate, true);
        String formattedDate = DateFormat('kk:mm:ss EEE d-MM-yyyy').format(dateTime);
        post.createdDate = formattedDate;
      })
          .toList(growable: false);
    }
    return List.empty();
  }

  void doGetPostDetails() {}

  void doUpdatePostStatus() {}

  Future<Map> postRequest(
      {@required String path, Map<String, dynamic> body}) async {
    final uri = Uri.http(_baseUrl, '$_contextRoot/$path');
    final results =
    await http.post(uri, headers: _headers, body: json.encode(body));
    if (results.statusCode == 200) {
      final jsonObject = json.decode(results.body);
      return jsonObject;
    }
    return null;
  }

  Future<Map> getRequest(
      {@required String path, Map<String, String> parameters}) async {
    final uri = Uri.http(_baseUrl, '$_contextRoot/$path', parameters);
    final results = await http.get(uri, headers: _headers);
    if (results.statusCode == 200) {
      final jsonObject = json.decode(results.body);
      return jsonObject;
    }
    return null;
  }

  Future<Map> postRequestWithToken({@required String path,
    Map<String, dynamic> body,
    String accessToken}) async {
    final uri = Uri.http(_baseUrl, '$_contextRoot/$path');
    final results = await http.post(uri,
        headers: _headersWithToken(accessToken), body: json.encode(body));
    if (results.statusCode == 200) {
      final jsonObject = json.decode(results.body);
      return jsonObject;
    }
    return null;
  }

  Future<Map> getRequestWithToken({@required String path,
    Map<String, String> parameters,
    String accessToken}) async {
    final uri = Uri.http(_baseUrl, '$_contextRoot/$path', parameters);
    final results =
    await http.get(uri, headers: _headersWithToken(accessToken));
    if (results.statusCode == 200) {
      final jsonObject = json.decode(results.body);
      return jsonObject;
    }
    return null;
  }

  Map<String, String> get _headers =>
      {'Accept': 'application/json', 'Content-type': 'application/json'};

  Map<String, String> _headersWithToken(String token) =>
      {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Authorization': token
      };
}
