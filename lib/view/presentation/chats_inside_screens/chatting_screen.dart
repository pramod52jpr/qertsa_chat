import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/controller/chatting_screen_provider.dart';
import 'package:qertsa/view/components/auth_button.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/image_full_screen.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/video_call_screen.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/voice_call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChattingScreen extends StatefulWidget {
  final String phoneNo;
  const ChattingScreen({super.key, required this.phoneNo});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final usersData = FirebaseFirestore.instance.collection("users");
  final chatsData = FirebaseFirestore.instance.collection("singleChats");
  final auth = FirebaseAuth.instance.currentUser;
  ValueNotifier<Contact?> contactDetail = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<ChatBottomBarProvider>(context,listen: false).accessContacts().then((value) {
      List<Contact> extractedContacts = Provider.of<ChatBottomBarProvider>(context,listen: false).contacts!.where((element) => element.phones![0].value.reverse.substring(0,10).reverse == widget.phoneNo).toList();
      if(extractedContacts.isNotEmpty){
        contactDetail.value = extractedContacts[0];
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final chattingScreenProvider=Provider.of<ChattingScreenProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
        valueListenable: contactDetail,
          builder: (context, detail, child) {
            return StreamBuilder(
              stream: usersData.snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  List user = snapshot.data!.docs.where((element) => element['phone'] == widget.phoneNo).toList();
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: user[0]['profileImage'].isEmpty?
                          const Center(
                            child: FaIcon(FontAwesomeIcons.user,color: Colors.black45,size: 20,),
                          ):
                          Image.network(
                            user[0]['profileImage'],
                            loadingBuilder: (context, child, loadingProgress) {
                              if(loadingProgress == null){
                                return child;
                              }
                              return SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null ?
                                  loadingProgress.cumulativeBytesLoaded/
                                      loadingProgress.expectedTotalBytes!: null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: FaIcon(FontAwesomeIcons.user,color: Colors.black45,size: 20,),
                              );
                            },
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail == null? widget.phoneNo : detail.displayName!,style: GoogleFonts.nunito(fontWeight: FontWeight.bold,fontSize: 16),),
                          // Text("+91${widget.phoneNo}",style: GoogleFonts.nunito(fontSize: 13),),
                        ],
                      ),
                    ],
                  );
                }
              return Row(
                children: [
                  CircleAvatar(
                    child: Container(),
                  ),
                  10.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail == null? widget.phoneNo : detail.displayName!,style: GoogleFonts.nunito(fontWeight: FontWeight.bold,fontSize: 16),),
                      // Text("+91${widget.phoneNo}",style: GoogleFonts.nunito(fontSize: 13),),
                    ],
                  ),
                ],
              );
            },);
      },),
        titleSpacing: 0,
        actions: [
          StreamBuilder(
            stream: usersData.snapshots(),
            builder: (context, userDataSnapshot) {
              if(userDataSnapshot.connectionState == ConnectionState.waiting){
                return const Offstage();
              }
              if(userDataSnapshot.hasError){
                return const Offstage();
              }
              if(!userDataSnapshot.hasData){
                return const Offstage();
              }
              List user = userDataSnapshot.data!.docs.where((element) => element['phone'] == widget.phoneNo).toList();
            return Row(
              children: [
                InkWell(
                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  onTap: () {
                    VideoCallScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.videocam_rounded),
                  ),
                ),
                ZegoSendCallInvitationButton(
                  resourceID: "zegouikit_call",
                  isVideoCall: true,
                  invitees: [
                    ZegoUIKitUser(id: user[0]['uid'], name: user[0]['name'])
                  ],
                ),
              ],
            );
          },),

          // InkWell(
          //   overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          //   onTap: () {
          //     VoiceCallScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
          //   },
          //   child: const Padding(
          //     padding: EdgeInsets.all(10.0),
          //     child: Icon(Icons.call),
          //   ),
          // )
        ],
      ),
      body: SafeArea(
        child: Consumer<ChattingScreenProvider>(builder: (context, value, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: chatsData.snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if(snapshot.hasError){
                          return const Center(
                            child: Text("Something went wrong"),
                          );
                        }
                        if(!snapshot.hasData){
                          return const Center(
                            child: Text("No recent chats"),
                          );
                        }
                        List data = snapshot.data!.docs.where((element) => (auth!.phoneNumber.reverse.substring(0,10).reverse == element['sender'] && widget.phoneNo == element['receiver']) || (auth!.phoneNumber.reverse.substring(0,10).reverse == element['receiver'] && widget.phoneNo == element['sender'])).toList().reversed.toList();
                        if(data.isEmpty){
                          return const Center(
                            child: Text("No recent chats"),
                          );
                        }
                        return ListView.builder(
                          itemCount: data.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                index != data.length-1?
                                DateTime.parse(data[index]['date'].toString()).year >= DateTime.parse(data[index+1]['date'].toString()).year
                                    ?DateTime.parse(data[index]['date'].toString()).month >= DateTime.parse(data[index+1]['date'].toString()).month
                                    ? DateTime.parse(data[index]['date'].toString()).day > DateTime.parse(data[index+1]['date'].toString()).day
                                    ?Align(
                                  alignment : Alignment.center,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Text(DateTime.parse(data[index]['date'].toString()).isToday ? "Today" : DateTime.parse(data[index]['date'].toString()).isYesterday ? "Yesterday" : DateFormat("dd MMM yyyy").format(DateTime.parse(data[index]['date'].toString())),style: GoogleFonts.nunito(color : Colors.white),)),
                                )
                                    :const Offstage()
                                    :const Offstage()
                                    :const Offstage()
                                    : Align(
                                  alignment : Alignment.center,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Text(DateTime.parse(data[index]['date'].toString()).isToday ? "Today" : DateTime.parse(data[index]['date'].toString()).isYesterday ? "Yesterday" : DateFormat("dd MMM yyyy").format(DateTime.parse(data[index]['date'].toString())),style: GoogleFonts.nunito(color : Colors.white),)),
                                ),
                                Align(
                                  alignment: data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse? Alignment.centerRight:Alignment.centerLeft,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 280),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          crossAxisAlignment: data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: data[index]["type"] == "image" ? EdgeInsets.all(2) : EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(15),
                                                    topRight: Radius.circular(15),
                                                    bottomLeft:data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse?Radius.circular(15): Radius.circular(0),
                                                    bottomRight:data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse?Radius.circular(0): Radius.circular(15),
                                                  ),
                                                  color: data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse? Color(0xFF0C63EE):Color(0xFFD9D9D9)
                                              ),
                                              child: data[index]["type"] == "image"
                                                ? GestureDetector(
                                                onTap : () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImageFullScreen(image: data[index]["image"].toString(),tag: "animateImage$index")));
                                                },
                                                  child: Hero(
                                                    tag : "animateImage$index",
                                                    child: SizedBox(
                                                      height : 150,
                                                      width : 150,
                                                      child: ClipRRect(
                                                        borderRadius : BorderRadius.only(
                                                          topLeft: Radius.circular(15),
                                                          topRight: Radius.circular(15),
                                                          bottomLeft:data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse?Radius.circular(15): Radius.circular(0),
                                                          bottomRight:data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse?Radius.circular(0): Radius.circular(15),
                                                        ),
                                                        child: Image.network(
                                                            data[index]["image"],
                                                            loadingBuilder: (context, child, loadingProgress) {
                                                              if(loadingProgress == null){
                                                                return child;
                                                              }
                                                              return SizedBox(
                                                                height: 50,
                                                                width: 50,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes != null ?
                                                                    loadingProgress.cumulativeBytesLoaded/
                                                                        loadingProgress.expectedTotalBytes!: null,
                                                                    strokeWidth: 1,
                                                                    color: data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse ? Colors.white : Colors.blue,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return const Center(
                                                                child: FaIcon(FontAwesomeIcons.user,color: Colors.black45,),
                                                              );
                                                            },
                                                            height: double.infinity,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                        ),
                                                                                                    ),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                data[index]["message"].toString(),
                                                style: GoogleFonts.nunito(color: data[index]['sender'].toString() == auth!.phoneNumber.reverse.substring(0,10).reverse?Colors.white:Colors.black),
                                              ),
                                            ),
                                            Text(DateFormat("hh:mm a").format(DateTime.parse(data[index]['date'].toString())),style: GoogleFonts.nunito(
                                                fontSize: 11,
                                                color: Colors.black),),
                                          ]),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },),
                  ),
                  StreamBuilder(
                    stream: usersData.snapshots(),
                    builder: (context, userDataSnapshot) {
                      if(userDataSnapshot.connectionState == ConnectionState.waiting){
                        return const Offstage();
                      }
                      if(userDataSnapshot.hasError){
                        return const Center(
                          child: Text("Something went wrong"),
                        );
                      }
                      if(!userDataSnapshot.hasData){
                        return const Offstage();
                      }
                      List user = userDataSnapshot.data!.docs.where((element) => element['phone'] == widget.phoneNo).toList();
                      return ChatBottomBar(phoneNo: widget.phoneNo,userFcm: user[0]['fcm_token']);
                  },),
                ],
              ),
              if(value.image!=null)
                Stack(
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.black
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(value.image!,fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          chattingScreenProvider.cancelImage();
                        },
                        child: Icon(Icons.cancel,color: Colors.white,size: 30),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () async{
                          if(!value.sendLoading){
                            chattingScreenProvider.sendAttachment("image", widget.phoneNo);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: value.sendLoading?
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ) :
                          const Icon(Icons.send,color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          );
        },),
      ),
    );
  }
}

class ChatBottomBar extends StatelessWidget {
  final String phoneNo;
  final String userFcm;
  const ChatBottomBar({super.key, required this.phoneNo, required this.userFcm});

  void playMusic(String path)async{
    try{
      final player = AudioPlayer();
      await player.play(AssetSource("recording/sample-15s.mp3"));
    }catch(e){
      print("the error is $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final chatBottomBarProvider=Provider.of<ChatBottomBarProvider>(context,listen: false);
    final chattingScreenProvider=Provider.of<ChattingScreenProvider>(context,listen: false);
    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xFFE7E4E4),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                context: context, builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  chattingScreenProvider.imagePicker(ImageSource.camera);
                                },
                                title: Text("Camera",style: GoogleFonts.nunito(),),
                                leading: Icon(Icons.camera_alt_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  chattingScreenProvider.imagePicker(ImageSource.gallery);
                                },
                                title: Text("Gallery",style: GoogleFonts.nunito(),),
                                leading: Icon(Icons.photo_library_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                              ),
                              AuthButton(onTap: () {
                                Navigator.of(context).pop();
                              }, title: "Cancel"),
                              20.height,
                            ],
                          );
                        },);
                      },
                      title: Text("Image",style: GoogleFonts.nunito(),),
                      leading: Icon(Icons.camera_alt_outlined),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    ),
                    // ListTile(
                    //   onTap: () {
                    //     Navigator.of(context).pop();
                    //     showModalBottomSheet(
                    //       showDragHandle: true,
                    //       context: context,
                    //       builder: (context) {
                    //         return Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             ListTile(
                    //               onTap: () {
                    //                 Navigator.of(context).pop();
                    //                 chattingScreenProvider.videoPicker(ImageSource.camera);
                    //               },
                    //               title: Text("Camera",style: GoogleFonts.nunito(),),
                    //               leading: Icon(Icons.camera_alt_outlined),
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    //             ),
                    //             ListTile(
                    //               onTap: () {
                    //                 Navigator.of(context).pop();
                    //                 chattingScreenProvider.videoPicker(ImageSource.gallery);
                    //               },
                    //               title: Text("Gallery",style: GoogleFonts.nunito(),),
                    //               leading: Icon(Icons.photo_library_outlined),
                    //               contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    //             ),
                    //             AuthButton(onTap: () {
                    //               Navigator.of(context).pop();
                    //             }, title: "Cancel"),
                    //             20.height,
                    //           ],
                    //         );
                    //       },);
                    //   },
                    //   title: Text("Video",style: GoogleFonts.nunito(),),
                    //   leading: Icon(Icons.photo_library_outlined),
                    //   contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    // ),
                    // ListTile(
                    //   onTap: () {
                    //
                    //   },
                    //   title: Text("Location",style: GoogleFonts.nunito(),),
                    //   leading: FaIcon(FontAwesomeIcons.locationArrow),
                    //   contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    // ),
                    AuthButton(onTap: () {
                      Navigator.of(context).pop();
                    }, title: "Cancel"),
                    20.height,
                  ],
                );
              },);
            },
            child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(Icons.add,color: Colors.grey,)),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100)),
              child: TextFormField(
                controller: chatBottomBarProvider.sendMessageController,
                minLines: 1,
                maxLines: 2,
                style: GoogleFonts.nunito(fontSize: 15),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: "Type message",
                    suffixIcon: InkWell(
                      onTap: () {
                        chatBottomBarProvider.sendMessage(phoneNo).then((value){
                          if(value){
                            chatBottomBarProvider.sendNotification(phoneNo,userFcm);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.send,color: Colors.grey,),
                      ),
                    )
                ),
              ),
            ),
          ),
          SizedBox(width: 5,),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          chattingScreenProvider.imagePicker(ImageSource.camera);
                        },
                        title: Text("Camera",style: GoogleFonts.nunito(),),
                        leading: Icon(Icons.camera_alt_outlined),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          chattingScreenProvider.imagePicker(ImageSource.gallery);
                        },
                        title: Text("Gallery",style: GoogleFonts.nunito(),),
                        leading: Icon(Icons.photo_library_outlined),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      ),
                      AuthButton(onTap: () {
                        Navigator.of(context).pop();
                      }, title: "Cancel"),
                      20.height,
                    ],
                  );
                },);
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(Icons.camera_alt,color: Colors.grey,),
            ),
          ),
          // SizedBox(width: 40,),
          InkWell(
            onTap: () {
              chatBottomBarProvider.isRecording?chatBottomBarProvider.stopRecording():chatBottomBarProvider.recordAudio();
            },
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Consumer<ChatBottomBarProvider>(builder: (context, value, child) {
                  return Icon(
                    value.isRecording?Icons.stop:Icons.mic,
                    color: Colors.grey,);
                },)
            ),
          )
        ],
      ),
    );
  }
}
