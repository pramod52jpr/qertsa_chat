import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FormButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  const FormButton({super.key,required this.onTap,required this.title,this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: BouncingWidget(
        onPressed: loading ? (){} : onTap,
        scaleFactor: 0.5,
        child: Container(
          width: double.infinity,
          height: 45,
          padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(colors: [Color(0xFFAECCFD),Color(0xFF1366EA)],begin: Alignment.topCenter,end: Alignment.bottomCenter,)
          ),
          child: Center(
            child: loading?
            LoadingAnimationWidget.dotsTriangle(
              color: Colors.white,
                size: 20):
            Text(title,style: GoogleFonts.nunito(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
          ),
        ),
      ),
    );
  }
}
