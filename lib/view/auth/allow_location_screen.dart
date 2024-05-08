import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/view/components/auth_button.dart';
import 'package:qertsa/view/presentation/dashboard_screen.dart';

class AllowLocationScreen extends StatelessWidget {
  const AllowLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatBottomBarProvider = Provider.of<ChatBottomBarProvider>(context,listen: false);
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
              Text("Location",style: GoogleFonts.nunito(fontWeight: FontWeight.bold,fontSize: 25),),
              SizedBox(height: 10,),
              Text("Get notify when someone send you messages",style: GoogleFonts.nunito(),),
              SizedBox(height: 20,),
              AuthButton(onTap: () {
                chatBottomBarProvider.accessLocation();
                DashboardScreen().launch(context,pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              }, title: "Allow")
            ],
          ),
        ),
      ),
    );
  }
}
