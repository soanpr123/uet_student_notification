import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/log_in_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/loading_overlay.dart';
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/UI/list_posts_screen.dart';

LoadingOverlay loadingOverlay;

class LogInScreen extends StatelessWidget {
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    loadingOverlay = LoadingOverlay.of(context);

    final bloc = LogInBloc();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bloc.addDataStream();
    });
    return BlocProvider<LogInBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: null,
        body: _buildBody(bloc, context),
      ),
    );
  }

  Widget _buildBody(LogInBloc bloc, BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        minimum: const EdgeInsets.all(0.0),
        child: Container(
          margin: EdgeInsets.all(0.0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, bottom: 30.0),
                child: Text(
                  "University of Engineering and Technology",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Common.PADDING),
                child: _buildEnterUsername(bloc),
              ),
              Padding(
                padding: const EdgeInsets.all(Common.PADDING),
                child: _buildEnterPassword(bloc),
              ),
              StreamBuilder<bool>(
                stream: bloc.isShowError,
                builder: (context, snapshot) {
                  return Visibility(
                    visible: snapshot.data ?? false,
                    child: Padding(
                      padding: const EdgeInsets.all(Common.PADDING),
                      child: Text(
                        "Login error. Please try again.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(Common.PADDING),
                child: _buildLoginButton(bloc, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterUsername(LogInBloc bloc) {
    return StreamBuilder(
        stream: bloc.streamUsername,
        builder: (context, snapshot) {
          String username = snapshot.hasData ? snapshot.data : null;
          usernameTextController.text = username;
          return IntrinsicHeight(
            child: TextField(
              obscureText: false,
              decoration: InputDecoration(
                hintText: "Username",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Common.INPUT_RADIUS)),
                fillColor: Colors.grey[100],
                filled: true,
              ),
              controller: usernameTextController,
            ),
          );
        });
  }

  Widget _buildEnterPassword(LogInBloc bloc) {
    return StreamBuilder(
        stream: bloc.streamPass,
        builder: (context, snapshot) {
          String pass = snapshot.hasData ? snapshot.data : null;
          passwordTextController.text = pass;
          return IntrinsicHeight(
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Common.INPUT_RADIUS)),
                fillColor: Colors.grey[100],
                filled: true,
              ),
              controller: passwordTextController,
            ),
          );
        });
  }

  Widget _buildLoginButton(LogInBloc bloc, BuildContext context) {
    return IntrinsicHeight(
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(Common.INPUT_RADIUS)),
          ),
          color: Colors.blue,
          child: Text(
            "Log in",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            loadingOverlay.show();
            bloc
                .doLogin(
                    usernameTextController.text, passwordTextController.text)
                .then((value) async {
              loadingOverlay.hide();
              if (value) {
                usernameTextController.text = "";
                passwordTextController.text = "";
                context.replaceWith(ListPostsScreen());
              } else {
                bloc.setShowError(true);
                passwordTextController.text = "";
              }
            });
          },
        ),
      ),
    );
  }
}
