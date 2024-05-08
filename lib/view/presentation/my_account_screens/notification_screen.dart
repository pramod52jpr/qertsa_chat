import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isPlaying=false;
  final AudioPlayer _audioPlayer=AudioPlayer(playerId: "12");

int id=0;
  Future<void> _showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: "@mipmap/launcher_icon",
    );
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails,iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(id++, 'plain title', 'plain body', notificationDetails, payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {
              isPlaying? _audioPlayer.pause()  :
              _audioPlayer.play(AssetSource("recording/sample-15s.mp3"));
              setState(() {
                isPlaying=!isPlaying;
              });
              _showNotification();
            }, icon: Icon(isPlaying?Icons.pause: Icons.play_arrow_rounded,size: 40,))
          ],
        ),
      ),
    );
  }
}
