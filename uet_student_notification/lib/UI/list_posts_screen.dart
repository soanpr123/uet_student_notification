import 'dart:ffi';
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
import 'package:uet_student_notification/UI/item_list_post.dart';
import 'package:uet_student_notification/UI/post_details_screen.dart';
import 'package:uet_student_notification/main.dart';

LoadingOverlay loadingOverlay;

class ListPostsScreen extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey _keyTopBar = GlobalKey();
  void Permison() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
     badge: true,
     sound: true
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ListPostsBloc();
    loadingOverlay = LoadingOverlay.of(context);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        print("day la mess $message");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      print('UET messenger : ${notification.body}');
      bloc.loadListPosts(context, false);
      // if (notification != null && android != null) {
      //
      // }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('ADay la tin nhan on Tap ${message.data}');
      showPostDetailsOnTap(context, bloc, message.data);
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
      Permison();
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
                final subtile = post.content ?? "Undefined";
                final firstCharacter = title.substring(0, 1);
                return InkWell(
                  onTap: () async {
                    if (!post.isRead) {
                      loadingOverlay.show();
                      await bloc.updatePostStatus(context, post.id);
                      loadingOverlay.hide();
                    }
                    context.navigateTo(PostDetailsScreen(postId: post.id));
                  },
                  child: ItemListPost(
                    index: index,
                    firstCharacter: firstCharacter,
                    title: title,
                    subtile: subtile,
                    createdDate: post.createdDate,
                    isRead: post.isRead,
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 2,
                color: Colors.grey,
              ),
              itemCount: posts.length,
            ),
    );
  }
}

void showPostDetailsOnTap(BuildContext context, ListPostsBloc bloc,
    Map<String, dynamic> message) async {
  String postId = "0";
  if (Platform.isAndroid) {
    postId = message["post_id"];
  } else if (Platform.isIOS) {
    postId = message['post_id'];
  }
  final id = int.parse(postId);
  loadingOverlay.show();
  await bloc.updatePostStatus(context, id);
  loadingOverlay.hide();
  context.navigateTo(PostDetailsScreen(postId: id));
}
