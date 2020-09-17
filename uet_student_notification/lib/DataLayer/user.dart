class User {
  final int id;
  final String username;
  final String fullName;
  final String token;

  User.fromJson(Map json)
      : id = json["user_id"],
        username = json["username"],
        fullName = json["fullname"],
        token = json["token"];
}
