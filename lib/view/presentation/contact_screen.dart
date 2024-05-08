import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/view/presentation/chats_inside_screens/chatting_screen.dart';

class ContactScreen extends StatefulWidget {

  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final firestore = FirebaseFirestore.instance.collection("users");
  @override
  void initState() {
    super.initState();
    Provider.of<ChatBottomBarProvider>(context,listen: false).accessContacts();
  }
  @override
  Widget build(BuildContext context) {
    final chatBottomBarProvider = Provider.of<ChatBottomBarProvider>(context,listen: false);
    return Scaffold(
      appBar: appBarWidget(
        "Contacts",
        color: Color(0xFF0C63EE),
        textColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                  controller: chatBottomBarProvider.searchController,
                  onChanged: (value) {
                    chatBottomBarProvider.searchContact();
                  },
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
              child: StreamBuilder(
                stream: firestore.snapshots(),
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
                  if(snapshot.hasData){
                    return Consumer<ChatBottomBarProvider>(
                      builder: (context, value, child) {
                      if(value.getContactLoading){
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if(value.contacts == null){
                        return const Center(
                          child: Text("something went wrong"),
                        );
                      }
                      List<Contact> data;
                      if(value.searchController.text.isNotEmpty){
                        data = value.searchedContacts.where((element) => snapshot.data!.docs.where((ele) => element.phones![0].value.toString().contains(ele['phone'])).toList().isNotEmpty).toList();
                      }else{
                        data = value.contacts!.where((element) => snapshot.data!.docs.where((ele) => element.phones![0].value.toString().contains(ele['phone'])).toList().isNotEmpty).toList();
                      }
                      if(data.isEmpty){
                        return const Center(
                          child: Text("No contacts exist"),
                        );
                      }
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                ChattingScreen(phoneNo: data[index].phones![0].value.reverse.substring(0,10).reverse).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                              },
                              title: Text(
                                data[index].displayName.toString(),
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Text(
                                data[index].phones![0].value.toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(fontSize: 13),
                              ),
                              leading: CircleAvatar(
                                child: Container(),
                              ),
                            );
                          });
                    },);
                  }
                return Center(
                  child: Text("No contacts exist"),
                );
              },),
            )
          ],
        ),
      ),
    );
  }
}
