import 'package:uet_student_notification/DataLayer/profile.dart';

class User {
  final int id;
  final int roleId;
  final String username;
  final String email;
  final String firebaseToken;
  final String emailVerifiedDate;
  final String createdDate;
  final String updatedDate;
  final Profile profile;
  String accessToken;
  String tokenType;
  String expireDate;

  User.fromJson(Map json)
      : id = json["id"],
        roleId = json["role_id"],
        username = json["username"],
        email = json["email"],
        profile = Profile.fromJson(json['profile']),
        firebaseToken = json["firebase_token"],
        emailVerifiedDate = json["email_verified_at"],
        createdDate = json["created_at"],
        updatedDate = json["updated_at"];
}
