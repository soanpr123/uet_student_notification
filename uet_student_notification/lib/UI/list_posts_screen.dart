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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final bloc = ListPostsBloc();
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 300), () async {
        progressDialog.style(message: "Loading posts...");
        await progressDialog.show();
        await bloc.checkAndUpdateFcmToken();
        bloc.loadListPosts(false);
      });
    });

    return BlocProvider<ListPostsBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: null,
        body: _buildBody(bloc),
      ),
    );
  }

  Widget _buildBody(ListPostsBloc bloc) {
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

        return _buildList(results, bloc);
      },
    );
  }

  Widget _buildList(List<Post> posts, ListPostsBloc bloc) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: bloc.enableLoadMore,
      controller: _refreshController,
      onLoading: () async {
        _refreshController.loadComplete();
        bloc.loadListPosts(true);
      },
      onRefresh: () async {
        _refreshController.refreshCompleted();
        bloc.loadListPosts(false);
      },
      child: posts.isEmpty
          ? Container(child: Text("No posts"), alignment: Alignment.center)
          : ListView.separated(
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(
                    post.title,
                    style: TextStyle(
                        color: post.isRead ? Colors.black : Colors.red),
                  ),
                  subtitle: Text(post.createdDate),
                  onTap: () async {
                    if(!post.isRead) {
                      progressDialog = ProgressDialog(context,
                          isDismissible: false,
                          type: ProgressDialogType.Normal);
                      progressDialog.style(message: "Updating...");
                      await progressDialog.show();
                      await bloc.updatePostStatus(post.id);
                      await progressDialog.hide();
                    }
                    context.navigateTo(PostDetailsScreen(post: post));
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: posts.length,
            ),
    );
  }
}
