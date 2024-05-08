import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/app_theme.dart';
import 'package:qertsa/controller/account_screen_provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/controller/chatting_screen_provider.dart';
import 'package:qertsa/controller/dashboard_screen_provider.dart';
import 'package:qertsa/controller/group_screen_provider.dart';
import 'package:qertsa/controller/login_screen_provider.dart';
import 'package:qertsa/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create:  (context) => LoginScreenProvider()),
          ChangeNotifierProvider(create: (context) => DashboardScreenProvider()),
          ChangeNotifierProvider(create: (context) => ChatBottomBarProvider()),
          ChangeNotifierProvider(create: (context) => AccountScreenProvider()),
          ChangeNotifierProvider(create: (context) => GroupScreenProvider()),
          ChangeNotifierProvider(create: (context) => ChattingScreenProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: SplashScreen(),
        ),
    );
  }
}