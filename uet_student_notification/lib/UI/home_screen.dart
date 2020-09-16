import 'package:flutter/cupertino.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: BlocProvider.of<HomeBLoc>(context).isLoggedIn,
      builder: (context, snapshot){
          final isLoggedIn = snapshot.data;
          if(isLoggedIn){

          }

      },
    );
  }
}