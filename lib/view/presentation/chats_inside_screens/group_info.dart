import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/components/utils.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/add_members.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/update_group.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;
  final List<Contact> contacts;
  GroupInfoScreen({super.key, required this.groupId, required this.contacts});

  final auth = FirebaseAuth.instance.currentUser;
  final usersdata = FirebaseFirestore.instance.collection("users");
  final groupsdata = FirebaseFirestore.instance.collection("groupList");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: groupsdata.snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(snapshot.hasError){
              return const Center(
                child: Text("something went wrong"),
              );
            }
            if(!snapshot.hasData){
              return const Center(
                child: Text("no data available"),
              );
            }
            List data = snapshot.data!.docs.where((element) => element['groupId'] == groupId).toList();
          return Center(
            child: Column(
              children: [
                50.height,
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  child: ClipOval(
                    child: data[0]['groupIcon'].toString().isEmpty ?
                    const Center(
                      child: FaIcon(FontAwesomeIcons.users,color: Colors.grey,size: 40),
                    ):
                    Image.network(
                      data[0]['groupIcon'],
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
                            strokeWidth: 3,
                            color: Colors.purple,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: FaIcon(FontAwesomeIcons.users,color: Colors.grey,size: 40),
                        );
                      },
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height:   double.infinity,
                    ),
                  ),
                ),
                10.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    30.width,
                    Text(data[0]['name'],style: GoogleFonts.aBeeZee(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xFF0C63EE)),),
                    10.width,
                    InkWell(
                        onTap: () {
                          UpdateGroup(groupId: groupId).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                        },
                        child: Icon(Icons.edit,size: 20,color: Colors.blue),
                    )
                  ],
                ),
                Text(data[0]['description'],style: GoogleFonts.aBeeZee(fontSize: 15),),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  onTap: () {
                    AddMembers(groupId: groupId, contacts: contacts).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  title: Text("Add member",style: GoogleFonts.aBeeZee()),
                  leading: Icon(Icons.add),
                ),
                StreamBuilder(
                  stream: usersdata.snapshots(),
                  builder: (context, snap) {
                    if(snap.connectionState == ConnectionState.waiting){
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if(snap.hasError){
                      return const Center(
                        child: Text("something went wrong"),
                      );
                    }
                    if(!snap.hasData){
                      return const Center(
                        child: Text("No data available"),
                      );
                    }
                    List users = snap.data!.docs.where((element) => data[0]['members'].toString().contains(element['phone'])).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      List<Contact> contactUser = contacts.where((element) => element.phones![0].value.reverse.substring(0,10).reverse == users[index]['phone']).toList();
                      return ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(contactUser.isNotEmpty ? contactUser[0].displayName : users[index]['phone'] == auth!.phoneNumber.reverse.substring(0,10).reverse ? "You" : users[index]['phone'],style: GoogleFonts.aBeeZee()),
                            10.width,
                            Text(data[0]['admins'].toString().contains(users[index]['phone']) ? "(admin)" : '',style: GoogleFonts.aBeeZee(color : Colors.blue),),
                          ],
                        ),
                        subtitle: Text(contactUser.isNotEmpty ? users[index]['phone'] : "~${users[index]['name']}",style: GoogleFonts.aBeeZee()),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: Image.network(
                              users[index]['profileImage'],
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
                                  child: FaIcon(FontAwesomeIcons.userLarge,color: Colors.black45,size: 18,),
                                );
                              },
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        trailing: users[index]['phone'] == auth!.phoneNumber.reverse.substring(0,10).reverse ?
                        null :
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          position: PopupMenuPosition.under,
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                  onTap: () {
                                    if(data[0]['admins'].toString().contains(users[index]['phone'])){
                                      List adminList = data[0]['admins'].toString().split(",");
                                      adminList.removeWhere((element) => element == users[index]['phone']);
                                      groupsdata.doc(data[0]['groupId']).update({
                                        "admins" : adminList.join(',')
                                      });
                                    }else{
                                      groupsdata.doc(data[0]['groupId']).update({
                                        "admins" : "${data[0]['admins']},${users[index]['phone']}"
                                      });
                                    }
                                  },
                                  child: Text(data[0]['admins'].toString().contains(users[index]['phone']) ? "Remove from Admin" : "Make admin")
                              ),
                              PopupMenuItem(
                                  onTap : () {
                                    if(data[0]['admins'].toString().contains(users[index]['phone'])){
                                      Utils.showFlushBar(context, "Remove from admin first", MessageType.info);
                                    }else {
                                      List membersList = data[0]['members'].toString().split(",");
                                      membersList.removeWhere((element) => element == users[index]['phone']);
                                      groupsdata.doc(data[0]['groupId']).update({
                                        "members": membersList.join(',')
                                      });
                                    }
                                  },
                                  child: Text("Remove")
                              ),
                            ];
                          },),
                      );
                    },);
                },)
              ],
            ),
          );
        },),
      ),
    );
  }
}
