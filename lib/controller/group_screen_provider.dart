import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qertsa/view/components/utils.dart';
import 'package:qertsa/view/presentation/dashboard_screen.dart';

class GroupScreenProvider with ChangeNotifier{
  final auth = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance.collection("groupList");

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<File?> groupIcon = ValueNotifier(null);
  TextEditingController groupName = TextEditingController();
  TextEditingController groupDesc = TextEditingController();
  ValueNotifier<String> groupMembers = ValueNotifier("");

  void emptyCredentials(){
    groupIcon.value = null;
    groupName.clear();
    groupDesc.clear();
    groupMembers.value = "";
  }

  bool _createGroupLoading = false;
  bool get createGroupLoading => _createGroupLoading;

  void createGroup(BuildContext context)async{
    _createGroupLoading = true;
    notifyListeners();
    try{
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      if(groupIcon.value == null){
        await firestore.doc(id).set({
          "groupId" : id,
          "groupIcon" : "",
          "name" : groupName.text,
          "description" : groupDesc.text,
          "created_by" : auth!.phoneNumber.reverse.substring(0,10).reverse,
          "admins" : auth!.phoneNumber.reverse.substring(0,10).reverse,
          "members" : "${auth!.phoneNumber.reverse.substring(0,10).reverse}${groupMembers.value.isEmpty ? '' : ','}${groupMembers.value}",
          "created_date" : DateTime.now().toString(),
        }).then((value){
          finish(context);
          groupIcon.value = null;
          groupName.clear();
          groupDesc.clear();
          groupMembers.value = "";
          Utils.showFlushBar(context, "Group Created Successfully", MessageType.success);
        });
      }else{
        String imgName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref("/groupIcons/$imgName");
        UploadTask uploadTask = ref.putFile(groupIcon.value!.absolute);
        await Future.value(uploadTask);
        String url = await ref.getDownloadURL();
        await firestore.doc(id).set({
          "groupId" : id,
          "groupIcon" : url,
          "name" : groupName.text,
          "description" : groupDesc.text,
          "created_by" : auth!.phoneNumber.reverse.substring(0,10).reverse,
          "admins" : auth!.phoneNumber.reverse.substring(0,10).reverse,
          "members" : "${auth!.phoneNumber.reverse.substring(0,10).reverse}${groupMembers.value.isEmpty ? '' : ','}${groupMembers.value}",
          "created_date" : DateTime.now().toString(),
        }).then((value){
          finish(context);
          groupIcon.value = null;
          groupName.clear();
          groupDesc.clear();
          groupMembers.value = "";
          Utils.showFlushBar(context, "Group Created Successfully", MessageType.success);
        });
      }
    }catch(e){
      rethrow;
    }finally{
      _createGroupLoading = false;
    }
    notifyListeners();
  }
  void updateGroup(BuildContext context,String groupId)async{
    _createGroupLoading = true;
    notifyListeners();
    try{
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      if(groupIcon.value == null){
        await firestore.doc(groupId).update({
          "name" : groupName.text,
          "description" : groupDesc.text
        }).then((value){
          finish(context);
          groupIcon.value = null;
          groupName.clear();
          groupDesc.clear();
          groupMembers.value = "";
          Utils.showFlushBar(context, "Group Updated Successfully", MessageType.success);
        });
      }else{
        String imgName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref("/groupIcons/$imgName");
        UploadTask uploadTask = ref.putFile(groupIcon.value!.absolute);
        await Future.value(uploadTask);
        String url = await ref.getDownloadURL();
        await firestore.doc(groupId).update({
          "groupIcon" : url,
          "name" : groupName.text,
          "description" : groupDesc.text
        }).then((value){
          finish(context);
          groupIcon.value = null;
          groupName.clear();
          groupDesc.clear();
          groupMembers.value = "";
          Utils.showFlushBar(context, "Group Updated Successfully", MessageType.success);
        });
      }
    }catch(e){
      rethrow;
    }finally{
      _createGroupLoading = false;
    }
    notifyListeners();
  }

  bool _addMemberLoading = false;
  bool get addMemberLoading => _addMemberLoading;

  void addMembers(BuildContext context, String groupId)async{
    _addMemberLoading = true;
    notifyListeners();
    await firestore.doc(groupId).update({
      "members" : groupMembers.value,
    });
    Navigator.pop(context);
    Utils.showFlushBar(context, "Members Added", MessageType.success);
    _addMemberLoading = false;
    notifyListeners();
  }


  List<Contact>? _contacts;
  List<Contact>? get contacts => _contacts;
  bool _getContactLoading = false;
  bool get getContactLoading => _getContactLoading;

  Future<void> accessContacts()async{
    QuerySnapshot userslist = await FirebaseFirestore.instance.collection("users").get();
    _getContactLoading = true;
    notifyListeners();
    PermissionStatus permissionStatus = await Permission.contacts.status;
    if(permissionStatus!=PermissionStatus.granted){
      permissionStatus = await Permission.contacts.request();
      if(permissionStatus!=PermissionStatus.granted){
        accessContacts();
      }
    }else{
      List<Contact> cont= await ContactsService.getContacts();
      cont.retainWhere((element) => element.phones!.isNotEmpty && element.phones![0].value!.length>=10 && userslist.docs.where((ele) => ele['phone'] == element.phones![0].value.reverse.substring(0,10).reverse).toList().isNotEmpty);
      for(var i =0;i<cont.length;i++){
        if(_contacts!= null){
          if(contacts!.where((element) => element.phones![0].value.reverse.substring(0,10).reverse == cont[i].phones![0].value.reverse.substring(0,10).reverse).toList().isEmpty){
            _contacts!.add(cont[i]);
          }
        }else{
          _contacts = cont.isNotEmpty ? [cont[0]] : [];
        }
      }
    }
    _getContactLoading = false;
    notifyListeners();
  }

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

  void sendAttachment(String type,String groupId)async{
    _sendLoading = true;
    notifyListeners();
    final groupChats = FirebaseFirestore.instance.collection("groupChats");
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    String imgName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref("/groupChatImages/$imgName");
    UploadTask uploadTask = ref.putFile(_image!);
    await Future.value(uploadTask);
    String url = await ref.getDownloadURL();
    Map<String,dynamic> data = {
      "id" : id,
      "groupId" : groupId,
      "sender" : auth!.phoneNumber.reverse.substring(0,10).reverse,
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
    await groupChats.doc(id).set(data);
    _image = null;
    _sendLoading = false;
    notifyListeners();
  }

}