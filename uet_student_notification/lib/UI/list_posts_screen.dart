
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/list_posts_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/UI/post_details_screen.dart';

ProgressDialog progressDialog;

class ListPostsScreen extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey _keyTopBar = GlobalKey();

  double _calculateListHeight(double containerHeight){
    if(_keyTopBar.currentContext != null) {
      final RenderBox renderBoxRed = _keyTopBar.currentContext
          .findRenderObject();
      final topHeight = renderBoxRed.size.height;
      return containerHeight - topHeight - 150;
    }
    return containerHeight - 180;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ListPostsBloc();
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("UET onMessage: $message");
        progressDialog.style(message: "Loading posts...");
        await progressDialog.show();
        bloc.loadListPosts(context, false);
      },
      onBackgroundMessage: null,
      onLaunch: (Map<String, dynamic> message) async{
        print("UET onLaunch: $message");
        showPostDetailsOnTap(context, bloc, message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("UET onResume: $message");
        showPostDetailsOnTap(context, bloc, message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) async {
      if (token != null) {
        print("FCM Token: $token");
        bloc.saveFcmToken(token);
      }
      bloc.loadUsername();
      progressDialog.style(message: "Loading posts...");
      await progressDialog.show();
      await bloc.checkAndUpdateFcmToken();
      bloc.loadListPosts(context, false);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    });

    return BlocProvider<ListPostsBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: null,
        body: _buildBody(context, bloc),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ListPostsBloc bloc) {
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
            child: Column(
              children: <Widget>[
                Row(
                  key: _keyTopBar,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    StreamBuilder<String>(
                        stream: bloc.username,
                        builder: (context, snapshot) {
                          final username = snapshot.data;
                          if (username == null) {
                            return Text("Hello there");
                          }

                          return Text("Hello $username,");
                        }),
                    FlatButton(
                        onPressed: () => bloc.logOut(context),
                        color: Colors.blue,
                        child: Text("Log out"))
                  ],
                ),
                Container(
                    height: _calculateListHeight(MediaQuery.of(context).size.height),
                    child: _buildResults(bloc)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(ListPostsBloc bloc) {
    return StreamBuilder<List<Post>>(
      stream: bloc.listPosts,
      builder: (context, snapshot) {
        progressDialog.hide().then((value) {
          print("Hide: $value");
        });
        final results = snapshot.data;

        if (results == null) {
          return Container(
              child: Text("Loading..."), alignment: Alignment.center);
        }

        return _buildList(context, results, bloc);
      },
    );
  }

  Widget _buildList(
      BuildContext context, List<Post> posts, ListPostsBloc bloc) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: bloc.enableLoadMore,
      controller: _refreshController,
      onLoading: () async {
        _refreshController.loadComplete();
        bloc.loadListPosts(context, true);
      },
      onRefresh: () async {
        _refreshController.refreshCompleted();
        bloc.loadListPosts(context, false);
      },
      child: posts.isEmpty
          ? Container(child: Text("No posts"), alignment: Alignment.center)
          : ListView.separated(
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(
                    post.title ?? "Undefined",
                    style: TextStyle(
                        color: post.isRead ? Colors.black : Colors.red),
                  ),
                  subtitle: Text(post.createdDate ?? "Undefined"),
                  onTap: () async {
                    if (!post.isRead) {
                      progressDialog = ProgressDialog(context,
                          isDismissible: false,
                          type: ProgressDialogType.Normal);
                      progressDialog.style(message: "Updating...");
                      await progressDialog.show();
                      await bloc.updatePostStatus(context, post.id);
                      await progressDialog.hide();
                    }
                    context.navigateTo(PostDetailsScreen(postId: post.id));
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: posts.length,
            ),
    );
  }
}

void showPostDetailsOnTap(BuildContext context, ListPostsBloc bloc, Map<String, dynamic> message) async{
  final dynamic data = message['data'];
  final postId = data["post_id"];
  for(Post post in bloc.list){
    if(post.id == postId){
      progressDialog = ProgressDialog(context,
          isDismissible: false,
          type: ProgressDialogType.Normal);
      progressDialog.style(message: "Updating...");
      await progressDialog.show();
      await bloc.updatePostStatus(context, post.id);
      await progressDialog.hide();
    }
  }
  context.navigateTo(PostDetailsScreen(postId: postId));
}

