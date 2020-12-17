import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/log_in_bloc.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
import 'package:uet_student_notification/Common/navigation_extension.dart';
import 'package:uet_student_notification/UI/list_posts_screen.dart';

ProgressDialog progressDialog;

class LogInScreen extends StatelessWidget {
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final _storage = new FlutterSecureStorage();
  void read() async {
    String email = await _storage.read(key: "email");
    String pass = await _storage.read(key: "pass");
    print("value = $email");
  print("value = $pass");
  usernameTextController.text = email;
  passwordTextController.text = pass;
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      read();
    });
    final bloc = LogInBloc();
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Logging in...");
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
                child: _buildEnterUsername(),
              ),
              Padding(
                padding: const EdgeInsets.all(Common.PADDING),
                child: _buildEnterPassword(),
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

  Widget _buildEnterUsername() {
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
  }

  Widget _buildEnterPassword() {
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
            await progressDialog.show();
            bloc
                .doLogin(
                    usernameTextController.text, passwordTextController.text)
                .then((value) async {
              await progressDialog.hide();
              if (value) {
                _storage.write(key: "email", value: usernameTextController.text);
                _storage.write(key: "pass", value: passwordTextController.text);
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
