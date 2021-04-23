class Post {
  final int id;
  String title;
  String content;
  String createdDate;
  String updatedDate;
  bool isRead = false;
  String publicTime;

  Post(this.id);

  Post.fromJson(Map json)
      : id = json["id"],
        title = json["post_title"],
        content = json["post_content"],
        createdDate = json["created_at"],
        updatedDate = json["updated_at"],
        isRead = json["is_read"] == 1,
        publicTime = json["public_time"];
}
