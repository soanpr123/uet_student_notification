class Post {
  final int id;
  String title;
  String content;
  String date;
  bool isRead = false;

  Post(this.id);

  Post.fromJson(Map json)
      : id = json["post_id"],
        title = json["post_title"],
        content = json["post_content"],
        date = json["post_date"],
        isRead = json["is_read"];
}
