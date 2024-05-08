import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/group_screen_provider.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/group_chatting_screen.dart';
import 'package:qertsa/view/presentation/create_group.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final auth = FirebaseAuth.instance.currentUser;

  final groupsList = FirebaseFirestore.instance.collection("groupList");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GroupScreenProvider>(context,listen: false).accessContacts();
  }

  @override
  Widget build(BuildContext context) {
    final groupScreenProvider = Provider.of<GroupScreenProvider>(context,listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(100)),
                child: TextFormField(
                  style: GoogleFonts.nunito(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search",
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<GroupScreenProvider>(
                builder: (context, value, child) {
                  return StreamBuilder(
                    stream: groupsList.snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting || value.contacts == null){
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
                          child: Text("no groups exist"),
                        );
                      }
                      List data = snapshot.data!.docs.where((element) => element['members'].toString().contains(auth!.phoneNumber.reverse.substring(0,10).reverse)).toList();
                      if(data.isEmpty){
                        return const Center(
                          child: Text("no groups exist"),
                        );
                      }
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                GroupChattingScreen(group: data[index],contacts: value.contacts!).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                              },
                              // contentPadding: EdgeInsets.zero,
                              title: Text(
                                data[index]['name'],
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Text(
                                data[index]['description'],
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(fontSize: 13),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: ClipOval(
                                  child: data[index]['groupIcon'].toString().isEmpty ?
                                  const Center(
                                    child: FaIcon(FontAwesomeIcons.users,color: Colors.black45,),
                                  ):
                                  Image.network(
                                    data[index]['groupIcon'],
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
                                        child: FaIcon(FontAwesomeIcons.users,color: Colors.black45,),
                                      );
                                    },
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("9.32 AM",style: GoogleFonts.nunito(),),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Color(0xFF0C63EE),
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child: Center(child: Text("3",style: GoogleFonts.nunito(color: Colors.white,fontWeight: FontWeight.bold),)),
                                  )
                                ],
                              ),
                            );
                          });
                    },);
                },
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0C63EE),
        onPressed: () {
          const CreateGroup().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
        },
        child: const Icon(Icons.group_add,color: Colors.white),
      ),
    );
  }
}
