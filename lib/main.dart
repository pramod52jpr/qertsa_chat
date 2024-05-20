import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
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
import 'package:qertsa/notification_services.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/chatting_screen.dart';
import 'package:qertsa/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(MyApp.navigatorKey);

  AwesomeNotifications().initialize(
    "resource://drawable/notification_icon",
    [
      NotificationChannel(
          channelKey: "basic_channel",
          channelName: "Basic Notifications",
          channelDescription: "My Message Notification",
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          soundSource: "resource://raw/notification_sound"
      )
    ]
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    runApp(const MyApp());
  });
}

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  // AwesomeNotifications().initialize(
  //     "resource://drawable/notification_icon",
  //     [
  //       NotificationChannel(
  //           channelKey: "basic_channel",
  //           channelName: "Basic Notifications",
  //           channelDescription: "My Message Notification",
  //           defaultColor: Colors.teal,
  //           importance: NotificationImportance.High,
  //           channelShowBadge: true,
  //           playSound: true,
  //           soundSource: "resource://raw/notification_sound"
  //       )
  //     ]
  // );
  await Firebase.initializeApp();
  NotificationServices().createNotification(message);
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   notificationServices.createNotification(message);
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationServices.createNotification(message);
    });
    AwesomeNotifications().setListeners(
        onActionReceivedMethod : onActionReceiveMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
    notificationServices.requestAwesomePermission();
    // notificationServices.requestNotificationPermission();
    // notificationServices.firebaseInit(context);
    // notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value){
      print("device token : ${value}");
    });
  }
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
          navigatorKey: MyApp.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: SplashScreen(),
        ),
    );
  }
}



@pragma("vm:entry-point")
Future<void> onActionReceiveMethod(ReceivedAction receivedAction) async{
  AwesomeNotifications().getGlobalBadgeCounter().then((value){
    AwesomeNotifications().setGlobalBadgeCounter(value-1);
  });
  log(receivedAction.toString());
  if(receivedAction.payload!['type'] == "chat"){
    MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ChattingScreen(phoneNo: receivedAction.payload!['number']!)));
  }
}

@pragma("vm:entry-point")
Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async{
  AwesomeNotifications().getGlobalBadgeCounter().then((value){
    AwesomeNotifications().setGlobalBadgeCounter(value-1);
  });
}
