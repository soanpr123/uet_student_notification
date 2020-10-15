import 'package:intl/intl.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class PagePost {

  Pagination pagination;
  List<Post> data = List();

  PagePost({this.pagination, this.data});

  PagePost.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    data.clear();
    if (json['data'] != null) {
      DateFormat format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.sss'Z'");
      json['data'].forEach((v) {
        final post = Post.fromJson(v);
        if(post.createdDate != null) {
          DateTime dateTime = format.parse(post.createdDate, true).toLocal();
          String formattedDate = DateFormat('kk:mm:ss EEE d-MM-yyyy').format(
              dateTime);
          post.createdDate = formattedDate;
        }
        data.add(post);
      });
      data.sort((a, b) => b.id.compareTo(a.id));
    }
  }
}

class Pagination {
  int total;
  String perPage;
  int currentPage;
  int lastPage;
  int from;
  int to;

  Pagination(
      {this.total,
        this.perPage,
        this.currentPage,
        this.lastPage,
        this.from,
        this.to});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['per_page'] = this.perPage;
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}