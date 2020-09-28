class Post {
  final int id;
  String title;
  String content;
  String createdDate;
  String updatedDate;
  bool isRead = false;

  Post(this.id);

  Post.fromJson(Map json)
      : id = json["post_id"],
        title = json["post_title"],
        content = json["post_content"],
        createdDate = json["created_at"],
        updatedDate = json["updated_at"],
        isRead = json["is_read"];
}
