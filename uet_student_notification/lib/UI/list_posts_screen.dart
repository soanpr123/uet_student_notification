import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/list_posts_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/DataLayer/post.dart';

ProgressDialog progressDialog;
class ListPostsScreen extends StatelessWidget{

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }
  
  @override
  Widget build(BuildContext context) {
    final bloc = ListPostsBloc();
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Loading posts...");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 300), () async {
        bloc.loadListPosts();
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

  Widget _buildBody(ListPostsBloc bloc){
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

  Widget _buildResults(ListPostsBloc bloc){
    return StreamBuilder<List<Post>>(
      stream: bloc.listPosts,
      builder: (context, snapshot) {
          final results = snapshot.data;

          if(results == null){
            return Container(child: Text("Loading..."),
            alignment: Alignment.center);
          }

          if(results.isEmpty){
            return Container(child: Text("No posts"),
                alignment: Alignment.center);
          }

          return _buildList(results);
      },
    );
  }

  Widget _buildList(List<Post> posts){
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.separated(
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.title),
              onTap: (){
                //do something
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: posts.length),
    );
  }
}