import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uet_student_notification/DataLayer/user.dart';

class APIClient {
  final _baseUrl = "112.137.129.31";
  final _contextRoot = 'api';
  final _login = "auth/login";

  Future<User> doLogin(String username, String password) async{
    final result = await postRequest(
        path: _login,
        body: {'username': username, 'password': password});
    if(result != null) {
      final user = User.fromJson(result['user_data']);
      user.accessToken = result['access_token'];
      user.tokenType = result['token_type'];
      user.expireDate = result['expires_at'];
      return user;
    }
    return null;
  }

  void doUpdateToken() {}

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
    final jsonObject = json.decode(results.body);
    return jsonObject;
  }

  Map<String, String> get _headers =>
      {'Accept': 'application/json', 'Content-type': 'application/json'};
}
