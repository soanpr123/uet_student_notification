import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/post_details_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/loading_overlay.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:url_launcher/url_launcher.dart';

LoadingOverlay loadingOverlay;

class PostDetailsScreen extends StatelessWidget {
  final postId;

  const PostDetailsScreen({Key key, @required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    loadingOverlay = LoadingOverlay.of(context);

    final bloc = PostDetailsBloc();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loadingOverlay.show();
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
          final result = snapshot.data;
          if (result == null) {
            return Container(
                child: Text("Loading..."), alignment: Alignment.center);
          }

          loadingOverlay.hide();
          return SingleChildScrollView(
            child: Container(
                child: Html(
                    data: result.content,
                    shrinkWrap: true,
                    onLinkTap: (url) {
                      _launchURL(url);
                    },
                    style: {
                      // tables will have the below background color
                      "table": Style(
                        backgroundColor: Colors.white,
                      ),
                      // some other granular customizations are also possible
                      "tr": Style(
                        border: Border.all(color: Colors.black),
                      ),
                      "th": Style(

                        backgroundColor: Colors.black54,
                      ),
                      "td": Style(
                        alignment: Alignment.topLeft,
                      ),
                      // text that renders h1 elements will be red
                      "h1": Style(color: Colors.black54),
                    }
                ),
                alignment: Alignment.topCenter),
          );
        });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
