import 'package:flutter/cupertino.dart';
import 'package:uet_student_notification/BLoC/bloc_provider.dart';
import 'package:uet_student_notification/BLoC/home_bloc.dart';
import 'package:uet_student_notification/UI/log_in_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = HomeBLoc();
    WidgetsBinding.instance.addPostFrameCallback((_) => bloc.checkLoggedIn());

    return BlocProvider<HomeBLoc>(
      bloc: bloc,
      child: StreamBuilder<bool>(
        stream: bloc.isLoggedIn,
        builder: (context, snapshot){
            final isLoggedIn = snapshot.data;
            if(isLoggedIn != null && isLoggedIn){
              return Center(
                child: Text("Logged In"),
              );
            }

            return LogInScreen();
        },
      ),
    );
  }
}