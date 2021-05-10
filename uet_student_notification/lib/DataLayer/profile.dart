class Profile {
  int id;
  int userId;
  String fullname;
  String birthday;
  int gender;
  String address;
  String phone;
  String createdAt;
  String updatedAt;

  Profile(
      {this.id,
      this.userId,
      this.fullname,
      this.birthday,
      this.gender,
      this.address,
      this.phone,
      this.createdAt,
      this.updatedAt});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    fullname = json['fullname'];
    birthday = json['birthday'];
    gender = json['gender'];
    address = json['address'];
    phone = json['phone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['fullname'] = this.fullname;
    data['birthday'] = this.birthday;
    data['gender'] = this.gender;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
