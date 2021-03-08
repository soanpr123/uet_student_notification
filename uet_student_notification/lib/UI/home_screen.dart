import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/home_bloc.dart';
import 'package:uet_student_notification/BLoC/log_in_bloc.dart';
import 'package:uet_student_notification/Common/loading_overlay.dart';
import 'package:uet_student_notification/UI/list_posts_screen.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';
import 'package:uet_student_notification/Common/common.dart' as Common;
LoadingOverlay loadingOverlay;
class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    loadingOverlay = LoadingOverlay.of(context);
    final storage = new FlutterSecureStorage();
    final bloc = HomeBLoc();
final blocs=LogInBloc();
    WidgetsBinding.instance.addPostFrameCallback((_){
      bloc.checkLoggedIn();
    });

    return BlocProvider<HomeBLoc>(
      bloc: bloc,
      child: StreamBuilder<bool>(
        stream: bloc.isLoggedIn,
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data;
          if (isLoggedIn == null) {

            return _buildWelcome(blocs,context,isLoggedIn,loadingOverlay,storage);
          }

          if (isLoggedIn) {
            return ListPostsScreen();
          }

          return LogInScreen();
        },
      ),
    );
  }

  Widget _buildWelcome(LogInBloc bloc, BuildContext context,bool isLogin,LoadingOverlay loadingOverlay,FlutterSecureStorage storage) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      bloc.CheckToken().then((value)async{
        print("check$value");
        if(value){
          // TODO: implement Code here
          // SharedPreferences preferences = await SharedPreferences.getInstance();
          // String email =  preferences.getString(Common.USER_NAME);
          // await storage.read(key: Common.PASS).then((value) {
          //     if(email != null && value != null){
          //       loadingOverlay.show();
          //       bloc.doLogin(email, value).then((value){
          //         loadingOverlay.hide();
          //         if (value) {
          //           Navigator.of(context)
          //               .pushReplacement(MaterialPageRoute(builder: (context) => ListPostsScreen()));
          //         } else {
          //           bloc.setShowError(true);
          //         }
          //       });
          //     }
          // });
        }else{
          // TODO: implement Code here
        }
      });

    });

    return Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        color: Colors.white);

  }

}

