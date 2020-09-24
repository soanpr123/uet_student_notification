library common;

import '../DataLayer/post.dart';

const String IS_LOGGED_IN = "is_logged_in";
const String USER_ID = "user_id";
const String USER_NAME = "user_name";
const String ACCESS_TOKEN = "access_token";
const String TOKEN_TYPE = "token_type";

const double PADDING = 16.0;
const double INPUT_RADIUS = 10.0;

final Map<String, Post> _items = <String, Post>{};

Post _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final int postId = data['post_id'];
  final Post item = _items.putIfAbsent(
      postId.toString(),
      () => Post(postId)
        ..title = data['post_title']
        ..content = data['post_content']
        ..date = data['post_date']);
  return item;
}
