import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/log_in_bloc.dart';
import 'package:uet_student_notification/common.dart' as Common;

class LogInScreen extends StatelessWidget {
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final bloc = LogInBloc();
    return BlocProvider<LogInBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: null,
        body: _buildBody(bloc),
      ),
    );
  }

  Widget _buildBody(LogInBloc bloc) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        left: true,
        top: true,
        right: true,
        bottom: true,
        minimum: const EdgeInsets.all(Common.PADDING),
        child: Container(
          margin: EdgeInsets.only(left: Common.PADDING, right: Common.PADDING),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "University of Engineering and Technology",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
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
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.all(Common.PADDING),
                  child: _buildEnterPassword(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Common.PADDING),
                child: _buildLoginButton(bloc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterUsername() {
    return TextField(
      obscureText: false,
      decoration: InputDecoration(
        hintText: "Username",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Common.INPUT_RADIUS)),
        fillColor: Colors.grey[300],
        filled: true,
      ),
      controller: usernameTextController,
    );
  }

  Widget _buildEnterPassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Password",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Common.INPUT_RADIUS)),
        fillColor: Colors.grey[300],
        filled: true,
      ),
      controller: passwordTextController,
    );
  }

  Widget _buildLoginButton(LogInBloc bloc) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Common.INPUT_RADIUS)),
        ),
        color: Colors.blue,
        child: Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          bloc.doLogin(usernameTextController.text, passwordTextController.text);
          usernameTextController.text = "";
          passwordTextController.text = "";
        },
      ),
    );
  }
}
