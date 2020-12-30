import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/list_posts_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/loading_overlay.dart';
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/DataLayer/post.dart';
import 'package:uet_student_notification/UI/post_details_screen.dart';

LoadingOverlay loadingOverlay;

class ListPostsScreen extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey _keyTopBar = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = ListPostsBloc();
    loadingOverlay = LoadingOverlay.of(context);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("UET onMessage: $message");
        bloc.loadListPosts(context, false);
      },
      onBackgroundMessage: null,
      onLaunch: (Map<String, dynamic> message) async {
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
      await bloc.checkAndUpdateFcmToken();
      bloc.loadListPosts(context, false);
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
        bottom: false,
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.all(0.0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: Common.PADDING),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: Common.PADDING,
                      left: Common.PADDING,
                      right: Common.PADDING),
                  child: Row(
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
                          child: Text(
                            "Log out",
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Common.PADDING),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: StreamBuilder<int>(
                      stream: bloc.unread,
                      builder: (context, snapshot) {
                        final unread = snapshot.data ?? 0;
                        if (unread > 0) {
                          FlutterAppBadger.updateBadgeCount(unread);
                        }
                        return Text("Unread: $unread posts");
                      },
                    ),
                  ),
                ),
                Flexible(child: _buildResults(bloc), fit: FlexFit.loose),
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
                final title = post.title ?? "Undefined";
                final firstCharacter = title.substring(0, 1);
                return ListTile(
                  leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: new SizedBox(
                          child: FloatingActionButton(
                        heroTag: "$index",
                        backgroundColor: Colors.blue,
                        child: Text(
                          firstCharacter,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        onPressed: null,
                      ))),
                  title: Text(
                    title,
                    style: TextStyle(
                        color: post.isRead ? Colors.black : Colors.red),
                  ),
                  subtitle: Text(post.createdDate ?? "Undefined"),
                  onTap: () async {
                    if (!post.isRead) {
                      loadingOverlay.show();
                      await bloc.updatePostStatus(context, post.id);
                      loadingOverlay.hide();
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

void showPostDetailsOnTap(BuildContext context, ListPostsBloc bloc,
    Map<String, dynamic> message) async {
  String postId = "0";
  if(Platform.isAndroid) {
    final dynamic data = message['data'];
    postId = data["post_id"];
  }else if(Platform.isIOS){
    postId = message['post_id'];
  }
  final id = int.parse(postId);
  for (Post post in bloc.list) {
    if (post.id == id) {
      loadingOverlay.show();
      await bloc.updatePostStatus(context, post.id);
      loadingOverlay.hide();
    }
  }
  context.navigateTo(PostDetailsScreen(postId: id));
}
