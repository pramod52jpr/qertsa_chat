import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool loading;
  const AuthButton({super.key,required this.onTap,required this.title,this.loading = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(colors: [Color(0xFFAECCFD),Color(0xFF1366EA)],begin: Alignment.topCenter,end: Alignment.bottomCenter,)
          ),
          child:loading?
          SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white)):
          Text(title,style: GoogleFonts.nunito(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
        ),
    );
  }
}
