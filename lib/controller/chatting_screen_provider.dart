import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class ChattingScreenProvider with ChangeNotifier{
  final auth = FirebaseAuth.instance.currentUser;

  bool _sendLoading = false;
  bool get sendLoading => _sendLoading;

  File? _image;
  File? get image => _image;
  void imagePicker(ImageSource source) async{
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    _image = File(pickedFile!.path);
    notifyListeners();
  }
  void cancelImage(){
    _image = null;
    notifyListeners();
  }

  void sendAttachment(String type, String receiver)async{
    _sendLoading = true;
    notifyListeners();
    final chatDatabase = FirebaseFirestore.instance.collection("singleChats");
    final singleChatUsers = FirebaseFirestore.instance.collection("singleChatUsersList");
    QuerySnapshot singleChatUsersList = await FirebaseFirestore.instance.collection("singleChatUsersList").get();
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    if(singleChatUsersList.docs.where((element) => (element['user1'] == auth!.phoneNumber.reverse.substring(0,10).reverse && element['user2'] == receiver) || (element['user1'] == receiver && element['user2'] == auth!.phoneNumber.reverse.substring(0,10).reverse)).toList().isEmpty){
      singleChatUsers.doc(id).set({
        "id" : id,
        "user1" : auth!.phoneNumber.reverse.substring(0,10).reverse,
        "user2" : receiver,
        "date" : DateTime.now().toString(),
      });
    }
    String imgName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref("/singleChatImages/$imgName");
    UploadTask uploadTask = ref.putFile(_image!);
    await Future.value(uploadTask);
    String url = await ref.getDownloadURL();
    Map<String,dynamic> data = {
      "id" : id,
      "sender" : auth!.phoneNumber.reverse.substring(0,10).reverse,
      "receiver" : receiver,
      "type" : type,
      "message" : "",
      "date" : DateTime.now().toString()
    };
    if(type == "image"){
      data.addAll({
        "image" : url,
        "video" : "",
        "latitude" : "",
        "longitude" : "",
      });
    }
    await chatDatabase.doc(id).set(data);
    _image = null;
    _sendLoading = false;
    notifyListeners();
  }

  File? _video;
  File? get video => _video;
  void videoPicker(ImageSource source) async{
    XFile? pickedFile = await ImagePicker().pickVideo(source: source);
    _video = File(pickedFile!.path);
    notifyListeners();
  }
}