class Notification {
  final int id;
  final String title;
  final String content;
  bool isRead;

  Notification.fromJson(Map json)
      : id = json[""],
        title = json[""],
        content = json[""];
}
