import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum MessageType{
  error,
  info,
  success,
}

class Utils{
  static void showFlushBar(BuildContext context,String message,MessageType type){
    Flushbar(
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      isDismissible: true,
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(10),
      messageColor: type == MessageType.success? Colors.white : type == MessageType.info ? Colors.black : Colors.white,
      backgroundColor: type == MessageType.success? Colors.green : type == MessageType.info ? Colors.yellow.shade700 : Colors.red,
      icon: type == MessageType.success? const Icon(Icons.offline_pin_rounded,color: Colors.white): type == MessageType.info ? const Icon(Icons.info,color: Colors.black): const Icon(Icons.error,color: Colors.white),
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  static Future<XFile> imagePicker(ImageSource imageSource, context)async{
    Navigator.of(context).pop();
    XFile? image = await ImagePicker().pickImage(source: imageSource);
    return image!;
  }
}