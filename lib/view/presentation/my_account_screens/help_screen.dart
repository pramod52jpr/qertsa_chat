import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                        overlayColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back),
                        )),
                    Text(
                      "How can we help you?",
                      style: GoogleFonts.nunito(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100)),
                  child: TextFormField(
                    style: GoogleFonts.nunito(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Popular Articles",
                      style: GoogleFonts.nunito(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    PopularArticle(onTap: () {

                    }, title: "How to make a video call"),
                    PopularArticle(onTap: () {

                    }, title: "How to stay safe on WhatsApp"),
                    PopularArticle(onTap: () {

                    }, title: "About Temporarily Banned Accounts"),
                    PopularArticle(onTap: () {

                    }, title: "About two-step verification"),
                  ],
                ),
                SizedBox(height: 70,),
                Image.asset("assets/images/help.png"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class PopularArticle extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  const PopularArticle({super.key,required this.onTap,required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text(
          title,
          style: GoogleFonts.nunito(
              color: Color(0xFF0C63EE),
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
        ),
      ),
    );
  }
}
