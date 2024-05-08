import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Container(
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
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        // Navigator.push(context, PageTransition(child: ChatScreen(), type: PageTransitionType.rightToLeft));
                      },
                      title: Text(
                        "Jacob",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(
                        "3.56 PM",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 13),
                      ),
                      leading: CircleAvatar(
                        child: Image.network(
                            "https://sialifehospital.com/wp-content/uploads/2021/04/testimonial-1.png"),
                      ),
                      trailing: InkWell(
                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                          onTap: () {

                          },
                          child: Icon(Icons.call,color: Color(0xFF0C63EE),)),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
