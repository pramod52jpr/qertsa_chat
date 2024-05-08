import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/auth/login_screen.dart';

class BeforeLogin2 extends StatelessWidget {
  const BeforeLogin2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Stack(children: [
          Image.asset("assets/images/before-2.png"),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      gradient: LinearGradient(
                          colors: [Color(0xFF0C63EE), Color(0xFF4C87E5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Column(
                    children: [
                      Text(
                        "Lets Connect with each other",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          LoginScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            "Let Start",
                            style: GoogleFonts.nunito(
                                color: Color(0xFF0C63EE),
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Powered by Aarvy",
                        style: GoogleFonts.nunito(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
