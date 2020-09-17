class Post {
  final int id;
  final String title;
  final String content;
  final String date;
  bool isRead;

  Post.fromJson(Map json)
      : id = json["post_id"],
        title = json["post_title"],
        content = json["post_content"],
        date = json["post_date"],
        isRead = json["is_read"];
}
