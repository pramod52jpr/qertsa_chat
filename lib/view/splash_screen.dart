import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/notification_services.dart';
import 'package:qertsa/view/auth/before_login_1.dart';
import 'package:qertsa/view/presentation/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser == null?
    Timer(const Duration(seconds: 2),() {
      const BeforeLogin1().launch(context,pageRouteAnimation: PageRouteAnimation.Slide,isNewTask: true);
    },)
    : Timer(const Duration(seconds: 2),() {
      DashboardScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide,isNewTask: true);
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Image.asset("assets/images/qertsa-logo.png",width: 200),
      )
    );
  }
}