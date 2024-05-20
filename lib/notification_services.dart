import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/chatting_screen.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/video_call_screen.dart';
import 'package:qertsa/view/presentation/contact_screen.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

// local notification code -----------------------------------------------------------------------------------
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings notificationSettings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint("user granted permission");
    }else if(notificationSettings.authorizationStatus == AuthorizationStatus.provisional){
      debugPrint("user provisional permission");
    }else{
      AppSettings.openAppSettings();
      debugPrint("user denied permission");
    }
  }

  void initLocalNotifications(BuildContext context,RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/launcher_icon');
    var darwinInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
          handleMessage(context, message);
      },
    );
  }
  void firebaseInit(BuildContext context)async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }else{
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message)async{
    var androidNotificationChannel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "Qertsa notification",
      importance: Importance.max,
    );

    var androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      channelDescription: "Qertsa description",
      importance: Importance.high,
      priority: Priority.high,
      // visibility: NotificationVisibility.public,
      ticker: 'ticker',
      icon: '@mipmap/launcher_icon',
    );
    var darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    await Future.delayed(Duration.zero,() {
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    },);
  }

  Future<void> setupInteractMessage(BuildContext context)async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
  void handleMessage(BuildContext context,RemoteMessage message){
    if(message.data["type"] == "chat"){
      ChattingScreen(phoneNo: message.data['number']).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
    }
    if(message.data["type"] == "videoCall"){
       // VideoCallScreen(token: message.data['token']).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
    }
  }
// local notification code end -------------------------------------------------------------------------

  void requestAwesomePermission(){
    AwesomeNotifications().isNotificationAllowed().then((value){
      if(!value){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> createNotification(RemoteMessage message)async{
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: Random.secure().nextInt(10000),
            channelKey: "basic_channel",
            title: message.notification!.title,
            body: message.notification!.body,
            notificationLayout: NotificationLayout.BigPicture,
            largeIcon: "asset://assets/images/qertsa-logo.png",
          payload: {
              "type" : message.data['type'],
              "number" : message.data['number']
          }
        )
    );
  }

  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }
  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      final firebaseFirestore = FirebaseFirestore.instance.collection("users");
      String token = await getDeviceToken();
      if(currentUser!=null){
        firebaseFirestore.doc(currentUser.uid).update({
          "fcm_token" : token
        });
      }
    });
  }

}