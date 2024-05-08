import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/auth/allow_location_screen.dart';
import 'package:qertsa/view/components/auth_button.dart';

class AllowNotificationScreen extends StatelessWidget {
  const AllowNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 80,),
              Image.asset(
                "assets/images/permission.png",
                width: 300,
              ),
              SizedBox(height: 50,),
              Text("Notification",style: GoogleFonts.nunito(fontWeight: FontWeight.bold,fontSize: 25),),
              SizedBox(height: 10,),
              Text("Get notify when someone send you messages",style: GoogleFonts.nunito(),),
              SizedBox(height: 20,),
              AuthButton(onTap: () {
                AllowLocationScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
              }, title: "Allow")
            ],
          ),
        ),
      ),
    );
  }
}
