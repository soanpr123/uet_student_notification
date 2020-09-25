import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uet_student_notification/DataLayer/user.dart';

class APIClient {
  final _baseUrl = "112.137.129.31";
  final _contextRoot = 'api';
  final _login = "auth/login";
  final _updateFCMToken = "v1/update-firebase-token";

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

  Future<bool> doUpdateToken(
      int userId, String accessToken, String fcmToken) async {
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

  void doGetListPosts() {}

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

  Future<Map> postRequestWithToken(
      {@required String path,
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

  Future<Map> getRequestWithToken(
      {@required String path,
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

  Map<String, String> _headersWithToken(String token) => {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Authorization': token
      };
}
