import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/view/components/auth_button.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Invite Contacts",
        color: Color(0xFF0C63EE),
        textColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
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
                      title: Text(
                        "Jacob",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(
                        "7765645456",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 13),
                      ),
                      leading: CircleAvatar(
                        child: Container(),
                      ),
                      trailing: AuthButton(onTap: () {
                        
                      }, title: "Invite"),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
