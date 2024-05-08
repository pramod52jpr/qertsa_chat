// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // class VideoCallScreen extends StatelessWidget {
// //   const VideoCallScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Stack(
// //           alignment: Alignment.bottomCenter,
// //           children: [
// //             Image.asset("assets/images/video-call.png",width: 500,),
// //             Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text("John Smith",style: GoogleFonts.nunito(fontSize: 20,fontWeight: FontWeight.bold),),
// //                 Text("00.29",style: GoogleFonts.nunito(fontWeight: FontWeight.bold),),
// //                 SizedBox(height: 20),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     InkWell(
// //                       onTap: () {
// //
// //                       },
// //                       child: Container(
// //                         padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(100),
// //                           ),
// //                           child: Icon(Icons.mic),
// //                       ),
// //                     ),
// //                     InkWell(
// //                       onTap: () {
// //                         Navigator.pop(context);
// //                       },
// //                       child: Container(
// //                           padding: EdgeInsets.all(15),
// //                           decoration: BoxDecoration(
// //                             color: Colors.red,
// //                             borderRadius: BorderRadius.circular(100),
// //                           ),
// //                           child: Icon(Icons.call_end,color: Colors.white,),
// //                       ),
// //                     ),
// //                     InkWell(
// //                       onTap: () {
// //
// //                       },
// //                       child: Container(
// //                           padding: EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(100),
// //                           ),
// //                           child: Icon(Icons.videocam_rounded),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 50),
// //               ],
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:async';
//
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// const appId = "754b0b975de04a7c8e892b79574f9335";
// const token = "007eJxTYJiyZur7wL8TYm6FFmlt6NpdI7W7YK+q/cngNosKbuGljZsUGMxNTZIMkizNTVNSDUwSzZMtUi0sjZLMLU3NTdIsjY1NTf1k0xoCGRn2CiWzMjJAIIjPy1BQlJibn5KckZiXl5rDwAAAbzwhxA==";
// const channel = "pramodchannel";
//
// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({Key? key}) : super(key: key);
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;
//
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }
//
//   Future<void> initAgora() async {
//     // retrieve permissions
//     await [Permission.microphone, Permission.camera].request();
//
//     //create the engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           toast("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           toast("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           toast("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           toast('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );
//
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//
//     await _engine.joinChannel(
//       token: token,
//       channelId: channel,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     _dispose();
//   }
//
//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }
//
//   // Create UI with local view and remote view
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Agora Video Call'),
//       ),
//       body: Stack(
//           alignment: Alignment.bottomCenter,
//         children:[
//           Stack(
//           children: [
//             Center(
//               child: _remoteVideo(),
//             ),
//             Align(
//               alignment: Alignment.topLeft,
//               child: SizedBox(
//                 width: 100,
//                 height: 150,
//                 child: Center(
//                   child: _localUserJoined
//                       ? AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   )
//                       : const CircularProgressIndicator(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//           Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("John Smith",style: GoogleFonts.nunito(fontSize: 20,fontWeight: FontWeight.bold),),
//                 Text("00.29",style: GoogleFonts.nunito(fontWeight: FontWeight.bold),),
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     InkWell(
//                       onTap: () {
//
//                       },
//                       child: Container(
//                         padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(100),
//                           ),
//                           child: Icon(Icons.mic),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                           padding: EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(100),
//                           ),
//                           child: Icon(Icons.call_end,color: Colors.white,),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//
//                       },
//                       child: Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(100),
//                           ),
//                           child: Icon(Icons.videocam_rounded),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 50),
//               ],
//             )
//     ]
//       ),
//     );
//   }
//
//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: channel),
//         ),
//       );
//     } else {
//       return const Text(
//         'Please wait for remote user to join',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
// }


import 'dart:convert';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/voice_call_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String? token;
  final String? fcmToken;
  const VideoCallScreen({super.key,this.token,this.fcmToken});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
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
              layoutType: Layout.oneToOne,
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
