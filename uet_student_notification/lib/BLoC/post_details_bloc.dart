import 'dart:async';

import 'package:uet_student_notification/BLoC/bloc.dart';
import 'package:uet_student_notification/DataLayer/post.dart';

class PostDetailsBloc extends Bloc {
  final _controller = StreamController<Post>();

  Stream<Post> get post => _controller.stream;

  void loadPostDetails(int postId) async {
    await Future.delayed(Duration(seconds: 2));
    Post post = Post(postId);
    post.content = "aifhafbhfbqerhoetfhalefjbalsjfbnasjfbasjf";
    _controller.sink.add(post);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
