import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/account_screen_provider.dart';
import 'package:qertsa/controller/dashboard_screen_provider.dart';
import 'package:qertsa/view/presentation/my_account_screens/help_screen.dart';
import 'package:qertsa/view/presentation/my_account_screens/invite_screen.dart';
import 'package:qertsa/view/presentation/my_account_screens/notification_screen.dart';
import 'package:qertsa/view/presentation/my_account_screens/profile_screen.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final auth = FirebaseAuth.instance.currentUser;
  final userData = FirebaseFirestore.instance.collection("users");
  @override
  Widget build(BuildContext context) {
    final dashboardScreenProvider=Provider.of<DashboardScreenProvider>(context,listen: false);
    final accountScreenProvider=Provider.of<AccountScreenProvider>(context,listen: false);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: userData.snapshots(),
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
                child: Text("No data available"),
              );
            }
            List data = snapshot.data!.docs.where((element) => element['uid'] == auth!.uid).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                color: Color(0xFFEDEDED),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          data[0]['profileImage'],
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
                              child: FaIcon(FontAwesomeIcons.users,color: Colors.black45,),
                            );
                          },
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height:   double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(data[0]['name'],style: GoogleFonts.nunito(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xFF0C63EE)),),
                    Text(data[0]['phone'],style: GoogleFonts.nunito(fontSize: 15),),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      onTap: () {
                        dashboardScreenProvider.setSelectedPageIndex(0);
                      },
                      title: Text("Chats"),
                      leading: Icon(Icons.chat_outlined,color: Color(0xFF0C63EE),),
                    ),
                    ListTile(
                      onTap: () {
                        ProfileScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                      title: Text("Account"),
                      leading: FaIcon(FontAwesomeIcons.user,color: Color(0xFF0C63EE),),
                    ),
                    ListTile(
                      onTap: () {
                        NotificationScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                      title: Text("Notifications"),
                      leading: FaIcon(FontAwesomeIcons.bell,color: Color(0xFF0C63EE),),
                    ),
                    ListTile(
                      onTap: () {
                        InviteScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                      title: Text("Invite a friend"),
                      leading: Icon(Icons.email_outlined,color: Color(0xFF0C63EE),),
                    ),
                    ListTile(
                      onTap: () {
                        HelpScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                      title: Text("Help"),
                      leading: Icon(Icons.help_outline,color: Color(0xFF0C63EE),),
                    ),
                    ListTile(
                      onTap: () {
                        accountScreenProvider.logout(context);
                      },
                      title: Text("Logout"),
                      leading: Icon(Icons.logout,color: Color(0xFF0C63EE),),
                    ),
                  ],
                ),
              )
            ],
          );
        },),
      ),
    );
  }
}
