import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint("user granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
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
      onDidReceiveNotificationResponse: (details) {
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
      visibility: NotificationVisibility.public,
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
    flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      notificationDetails,
    );
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
       VideoCallScreen(token: message.data['token']).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
    }
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