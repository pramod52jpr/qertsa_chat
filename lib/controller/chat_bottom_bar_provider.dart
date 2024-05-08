import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class ChatBottomBarProvider with ChangeNotifier{
  final auth = FirebaseAuth.instance.currentUser;

  final AudioRecorder audioRecorder=AudioRecorder();
  final AudioPlayer audioPlayer=AudioPlayer();
  final recordingName=DateTime.now().millisecondsSinceEpoch.toString();
  bool isRecording=false;

  void recordAudio()async{
    PermissionStatus permission= await Permission.microphone.status;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if(permission.isGranted){
      isRecording=true;
      await audioRecorder.start(const RecordConfig(), path: "${appDocDir.path}/$recordingName");
    }else{
      await Permission.microphone.request();
    }
    notifyListeners();
  }

  void stopRecording()async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if(await audioRecorder.isRecording()){
      isRecording=false;
      audioRecorder.stop().then((value){
        audioPlayer.play(DeviceFileSource("${appDocDir.path}/$recordingName"),volume: 1);
      });
    }
    notifyListeners();
  }

  void imagePicker(ImageSource imageSource, context)async{
    Navigator.of(context).pop();
    final image = await ImagePicker().pickImage(source: imageSource);
  }

  void imageOrVideoPicker(context)async{
    Navigator.of(context).pop();
    final media = await ImagePicker().pickMultipleMedia();
  }

  void accessLocation()async{
     LocationPermission permission= await Geolocator.checkPermission();
     if(permission != LocationPermission.always && permission !=LocationPermission.whileInUse){
       permission = await Geolocator.requestPermission();
       if(permission ==LocationPermission.denied || permission==LocationPermission.deniedForever){
         Geolocator.openAppSettings();
       }
     }else{
       var position = await Geolocator.getCurrentPosition();
     }
  }

  List<Contact>? _contacts;
  List<Contact>? get contacts => _contacts;
  bool _getContactLoading = false;
  bool get getContactLoading => _getContactLoading;

  Future<void> accessContacts()async{
    _getContactLoading = true;
    notifyListeners();
    QuerySnapshot userslist = await FirebaseFirestore.instance.collection("users").get();
    PermissionStatus permissionStatus = await Permission.contacts.status;
    if(permissionStatus!=PermissionStatus.granted){
      permissionStatus = await Permission.contacts.request();
      if(permissionStatus!=PermissionStatus.granted){
        accessContacts();
      }
    }else{
      List<Contact> cont= await ContactsService.getContacts();
      cont.retainWhere((element) => element.phones!.isNotEmpty && element.phones![0].value!.length>=10 && userslist.docs.where((ele) => ele['phone'] == element.phones![0].value.reverse.substring(0,10).reverse).toList().isNotEmpty);
      _contacts = cont.isNotEmpty? [cont[0]] : [];
      for(var i =0;i<cont.length;i++){
        if(contacts!.where((element) => element.phones![0].value.reverse.substring(0,10).reverse == cont[i].phones![0].value.reverse.substring(0,10).reverse).toList().isEmpty){
          _contacts!.add(cont[i]);
        }
      }
    }
    _getContactLoading = false;
    notifyListeners();
  }

  TextEditingController searchController = TextEditingController();
  List<Contact> _searchedContacts = [];
  List<Contact> get searchedContacts => _searchedContacts;
  void searchContact()async{
    _searchedContacts = _contacts!.where((Contact element) => element.displayName!.toLowerCase().contains(searchController.text.toLowerCase()) || element.phones![0].value!.toLowerCase().contains(searchController.text.toLowerCase())).toList();
    notifyListeners();
  }

  TextEditingController sendMessageController = TextEditingController();

  Future sendMessage(String receiver)async{
    if(sendMessageController.text.isEmpty) return;
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
    chatDatabase.doc(id).set({
      "id" : id,
      "sender" : auth!.phoneNumber.reverse.substring(0,10).reverse,
      "receiver" : receiver,
      "type" : "text",
      "message" : sendMessageController.text,
      "image" : "",
      "video" : "",
      "latitude" : "",
      "longitude" : "",
      "date" : DateTime.now().toString()
    });
      return true;
  }

  void sendNotification(String phoneNo,String fcmToken)async{
    String url = "https://fcm.googleapis.com/fcm/send";
    Map<String,dynamic> data = {
      "to" : fcmToken,
      "priority" : "high",
      "notification" : {
        "title" : auth!.phoneNumber.reverse.substring(0,10).reverse,
        "body" : sendMessageController.text,
      },
      "data" : {
        "type" : "chat",
        "number" : auth!.phoneNumber.reverse.substring(0,10).reverse,
      }
    };
    Response response = await post(
      Uri.parse(url),
      headers: {
        "Content-Type" : "application/json; charset=utf-8",
        "Authorization" : "key=AAAA5ywRf9E:APA91bEdkuySx4IhlSJ6wsDGs5QfZEDNYoGoWQ8qHXIRIoyBqtQMXPmoYwzHovr3cKMDPcPtHS1OZ1V_9AEj1SlEtzeyiuLYoIijBjvArFr7z5Mx1qrZV3ANSylY1jpmrR9NwvneYvfD"
      },
      body: jsonEncode(data)
    );
    sendMessageController.clear();
  }

  void sendMessageInGroup(String groupId)async{
    if(sendMessageController.text.isEmpty) return;
    final groupChats = FirebaseFirestore.instance.collection("groupChats");
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    groupChats.doc(id).set({
      "id" : id,
      "groupId" : groupId,
      "sender" : auth!.phoneNumber.reverse.substring(0,10).reverse,
      "type" : "text",
      "message" : sendMessageController.text,
      "image" : "",
      "video" : "",
      "latitude" : "",
      "longitude" : "",
      "date" : DateTime.now().toString()
    });
    sendMessageController.clear();
  }

  File? _video;
  File? get video => _video;
  void videoPicker(ImageSource source) async{
    XFile? pickedFile = await ImagePicker().pickVideo(source: source);
    _video = File(pickedFile!.path);
    notifyListeners();
  }

}