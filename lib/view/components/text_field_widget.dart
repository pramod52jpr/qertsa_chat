import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String? hint;
  final bool showTitle;
  final bool required;
  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.title,
    this.hint,
    this.showTitle = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if(showTitle)
          Row(
            children: [
              5.width,
              Text(title,style: GoogleFonts.nunito(fontWeight : FontWeight.w600)),
              5.width,
              if(required) const Text("*",style: TextStyle(color: Colors.red))
            ],
          ),
          2.height,
          TextFormField(
            controller: controller,
            validator: (value) {
              if(required){
                if(value!.isEmpty){
                  return "$title is required";
                }
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint ?? title,
              hintStyle: GoogleFonts.nunito(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder : OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder : OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder : OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
