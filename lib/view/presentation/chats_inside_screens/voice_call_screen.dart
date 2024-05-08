import 'dart:convert';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

class VoiceCallScreen extends StatefulWidget {
  final String? token;
  final String? fcmToken;
  const VoiceCallScreen({super.key,this.token,this.fcmToken});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  AgoraClient? client;
  final auth = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.token==null && widget.fcmToken!=null){
      generateToken().then((value){
        sendCallNotification(value, widget.fcmToken!);
        initAgoraClient(value);
      });
    }else{
      initAgoraClient(widget.token!);
    }
  }

  void sendCallNotification(String token, String fcmToken)async{
    String url = "https://fcm.googleapis.com/fcm/send";
    Map<String,dynamic> data = {
      "to" : fcmToken,
      "priority" : "high",
      "notification" : {
        "title" : auth!.phoneNumber.reverse.substring(0,10).reverse,
        "body" : "Calling...",
      },
      "data" : {
        "type" : "videoCall",
        "token" : token,
      }
    };
    Response response = await post(
        Uri.parse(url),
        headers: {
          "Content-Type" : "application/json; charset=utf-8",
          "Authorization" : "key=AAAA5ywRf9E:APA91bEdkuySx4IhlSJ6wsDGs5QfZEDNYoGoWQ8qHXIRIoyBqtQMXPmoYwzHovr3cKMDPcPtHS1OZ1V_9AEj1SlEtzeyiuLYoIijBjvArFr7z5Mx1qrZV3ANSylY1jpmrR9NwvneYvfD"
        },
        body: jsonEncode(data)
    );
  }

  initAgoraClient(String token)async{
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "754b0b975de04a7c8e892b79574f9335",
        tempToken: token,
        // tokenUrl: "https://agora-backend-du09.onrender.com/access_token?channelName=pramodchannel",
        channelName: "pramodchannel",
      ),
    );
    client!.initialize();
    setState(() {});
  }

  Future<String> generateToken()async{
    String url = "https://agora-backend-du09.onrender.com/access_token?channelName=pramodchannel";
    Response response = await get(Uri.parse(url));
    var result = jsonDecode(response.body);
    return result['token'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: client == null
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Stack(
          children: [
            AgoraVideoViewer(
              client: client!,
              layoutType: Layout.floating,
              showNumberOfUsers: true,
            ),
            AgoraVideoButtons(
              client: client!,
            ),
          ],
        ),
      ),
    );
  }
}
