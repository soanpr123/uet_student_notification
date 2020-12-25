import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/post_details_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/DataLayer/post.dart';

ProgressDialog progressDialog;

class PostDetailsScreen extends StatelessWidget {
  final postId;

  const PostDetailsScreen({Key key, @required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = PostDetailsBloc();
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Loading details...");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await progressDialog.show();
      bloc.loadPostDetails(context, postId);
    });

    return BlocProvider<PostDetailsBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder<String>(
            stream: bloc.title,
            builder: (context, snapshot) {
              final title = snapshot.data;
              return Text(
                title == null ? "Undefined" : title,
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        body: _buildBody(bloc),
      ),
    );
  }

  Widget _buildBody(PostDetailsBloc bloc) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        child: Container(
          margin: EdgeInsets.all(0.0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(Common.PADDING),
            child: _buildResults(bloc),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(PostDetailsBloc bloc) {
    return StreamBuilder<Post>(
        stream: bloc.post,
        builder: (context, snapshot) {
          progressDialog.hide().then((value) {
            print("Hide: $value");
          });

          final result = snapshot.data;
          if (result == null) {
            return Container(
                child: Text("Loading..."), alignment: Alignment.center);
          }
          return Container(
              child: Html(data: result.content),
              alignment: Alignment.topCenter);
        });
  }
}
