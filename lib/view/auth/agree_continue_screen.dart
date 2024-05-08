import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/auth/setup_starting_profile.dart';
import 'package:qertsa/view/components/auth_button.dart';

class AgreeAndContinueScreen extends StatelessWidget {
  const AgreeAndContinueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Welcome to qertsa Chat",style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),),
            Image.asset("assets/images/qertsa-logo.png",width: 200,),
            Column(
              children: [
                Center(
                  child: RichTextWidget(
                    list: [
                      TextSpan(text: "Tap To Agree ",style: GoogleFonts.nunito(color: black)),
                      TextSpan(text: "Terms ",style: GoogleFonts.nunito(color: Color(0xFF0C63EE),fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap=(){

                          }
                      ),
                      TextSpan(text: "And ",style: GoogleFonts.nunito(color: black)),
                      TextSpan(text: "Conditions",style: GoogleFonts.nunito(color: Color(0xFF0C63EE),fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap=(){

                          }
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                AuthButton(onTap: () {
                  SetUpStartingProfile().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                }, title: "Agree & Continue",)
              ],
            )

          ],
        ),
      ),
    );
  }
}
