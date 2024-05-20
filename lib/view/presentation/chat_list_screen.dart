import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/chatting_screen.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  
  final auth = FirebaseAuth.instance.currentUser;
  final usersList = FirebaseFirestore.instance.collection("users");
  final chatListData = FirebaseFirestore.instance.collection("singleChatUsersList");
  final chatsData = FirebaseFirestore.instance.collection("singleChats");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<ChatBottomBarProvider>(context,listen: false).accessContacts();
  }
  @override
  Widget build(BuildContext context) {
    final chatBottomBarProvider = Provider.of<ChatBottomBarProvider>(context,listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.height,
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            //   child: Container(
            //     decoration: BoxDecoration(
            //         color: Colors.grey.shade200,
            //         borderRadius: BorderRadius.circular(100)),
            //     child: TextFormField(
            //       style: GoogleFonts.nunito(),
            //       decoration: const InputDecoration(
            //         contentPadding: EdgeInsets.zero,
            //         border: OutlineInputBorder(borderSide: BorderSide.none),
            //         prefixIcon: Icon(Icons.search),
            //         hintText: "Search",
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Consumer<ChatBottomBarProvider>(
                builder: (context, value, child) {
                return StreamBuilder(
                  stream: chatListData.snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting || value.contacts == null){
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if(snapshot.hasError){
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }
                    if(snapshot.hasData){
                      List data = snapshot.data!.docs.where((element) => auth!.phoneNumber.reverse.substring(0,10).reverse == element['user1'] || auth!.phoneNumber.reverse.substring(0,10).reverse == element['user2']).toList();
                      if(data.isEmpty){
                        return const Center(
                          child: Text("No recent chats"),
                        );
                      }
                      return StreamBuilder(
                        stream: usersList.snapshots(),
                        builder: (context, userSnap) {
                          if(userSnap.connectionState == ConnectionState.waiting || value.contacts == null){
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if(userSnap.hasError){
                            return const Center(
                              child: Text("Something went wrong"),
                            );
                          }
                          return StreamBuilder(
                              stream: chatsData.snapshots(),
                              builder: (context, chatSnap) {
                                if(chatSnap.connectionState == ConnectionState.waiting || value.contacts == null){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if(chatSnap.hasError){
                                  return const Center(
                                    child: Text("Something went wrong"),
                                  );
                                }
                                // data.sort((a, b) => chatSnap.data!.docs.where((element) => user[0]['phone'] == element['sender'] || user[0]['phone'] == element['receiver']).toList())
                                return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  List user = userSnap.data!.docs.where((element) => auth!.phoneNumber.reverse.substring(0,10).reverse == data[index]['user1'] ? element['phone'] == data[index]['user2'] : element['phone'] == data[index]['user1'] ).toList();
                                  List<Contact> contactList = value.contacts!.where((element) => element.phones![0].value.reverse.substring(0,10).reverse == data[index]['user1'] || element.phones![0].value.reverse.substring(0,10).reverse == data[index]['user2']).toList();
                                  List chat = chatSnap.data!.docs.where((element) => (user[0]['phone'] == element['sender'] && auth!.phoneNumber.reverse.substring(0,10).reverse == element['receiver']) || (user[0]['phone'] == element['receiver'] && auth!.phoneNumber.reverse.substring(0,10).reverse == element['sender'])).toList();
                                  return ListTile(
                                    onTap: () {
                                      String phone = data[index]['user1'] == auth!.phoneNumber.reverse.substring(0,10).reverse ? data[index]['user2'] : data[index]['user1'];
                                      ChattingScreen(phoneNo: phone).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                                    },
                                    title: Text(
                                      contactList.isNotEmpty? contactList[0].displayName : data[index]['user1'] == auth!.phoneNumber.reverse.substring(0,10).reverse ? data[index]['user2'] : data[index]['user1'],
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    subtitle: chat.last['type'].toString() == "image" ?
                                    Row(
                                      children: [
                                        if(chat.last['sender'] == auth!.phoneNumber.reverse.substring(0,10).reverse)
                                        Text("✓",style: GoogleFonts.nunito(fontSize : 13)),
                                        Icon(Icons.camera,size: 16),
                                        2.width,
                                        Text("Image",style: GoogleFonts.nunito(fontSize : 13))
                                      ],
                                    ) :
                                    Text(
                                      chat.isNotEmpty
                                          ? chat.last['sender'] == auth!.phoneNumber.reverse.substring(0,10).reverse
                                          ? "✓ ${chat.last['message']}"
                                          : chat.last['message']
                                          : '',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(fontSize: 13),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: ClipOval(
                                        child: user[0]['profileImage'].toString().isEmpty?
                                        const Center(
                                          child: FaIcon(FontAwesomeIcons.user,color: Colors.black45,),
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
                                              child: FaIcon(FontAwesomeIcons.user,color: Colors.black45,),
                                            );
                                          },
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    // trailing: Column(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //   children: [
                                    //     Text("9.32 AM",style: GoogleFonts.nunito(),),
                                    //     Container(
                                    //       height: 20,
                                    //       width: 20,
                                    //       decoration: BoxDecoration(
                                    //           color: Color(0xFF0C63EE),
                                    //           borderRadius: BorderRadius.circular(100)
                                    //       ),
                                    //       child: Center(child: Text("3",style: GoogleFonts.nunito(color: Colors.white,fontWeight: FontWeight.bold),)),
                                    //     )
                                    //   ],
                                    // ),
                                  );
                                },);
                              });
                        },);
                    }
                    return const Offstage();
                  },);
              },),
            )
          ],
        ),
      ),
    );
  }
}


