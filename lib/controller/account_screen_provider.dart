import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/main.dart';
import 'package:qertsa/view/auth/login_screen.dart';

class AccountScreenProvider with ChangeNotifier{
  FirebaseAuth auth = FirebaseAuth.instance;
  void logout(BuildContext context){
    auth.signOut().then((value){
      onUserLogout();
      LoginScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Fade,isNewTask: true);
    });
  }
}