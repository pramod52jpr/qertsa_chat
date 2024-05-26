import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qertsa/main.dart';
import 'package:qertsa/model/user_model.dart';
import 'package:qertsa/notification_services.dart';
import 'package:qertsa/view/auth/agree_continue_screen.dart';
import 'package:qertsa/view/auth/allow_notification_screen.dart';
import 'package:qertsa/view/auth/verification_code_screen.dart';
import 'package:qertsa/view/components/utils.dart';
import 'package:qertsa/view/presentation/dashboard_screen.dart';

class LoginScreenProvider with ChangeNotifier{
  NotificationServices notificationServices = NotificationServices();

  int _timeLeft = 60;
  int get timeLeft => _timeLeft;
  late Timer _timer;
  Timer get timer => _timer;
  void changeTimer(){
    _timeLeft = 60;
    if(_timeLeft >= 0){
      _timer = Timer.periodic(Duration(seconds: 1),(timer) {
        _timeLeft--;
        notifyListeners();
      },);
    }
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;
  void changeLoading(bool status){
    _loading = status;
    notifyListeners();
  }

  String _countryCode = "+91";
  String get countryCode => _countryCode;
  void changeCountryCode(String newCode){
    _countryCode = newCode;
    notifyListeners();
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController phone = TextEditingController();
  TextEditingController otp = TextEditingController();

  String cameOtp = "";
  
  void verifyPhoneNumber(BuildContext context, {bool resend = false})async{
    if(phone.text.isEmpty){
      toast("Please enter mobile number");
    }else if(phone.text.length<10){
      toast("Please enter valid mobile number");
    }else {
      changeLoading(true);
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: _countryCode + phone.text,
        verificationCompleted: (phoneAuthCredential) {
          changeLoading(false);
        },
        verificationFailed: (error) {
          toast(error.toString().splitAfter("]"));
          changeLoading(false);
        },
        codeSent: (verificationId, forceResendingToken) {
          changeLoading(false);
          cameOtp = verificationId;
          changeTimer();
          resend ? null :
          VerificationCodeScreen().launch(
              context, pageRouteAnimation: PageRouteAnimation.Slide);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          changeLoading(false);
        },
      );
    }
    notifyListeners();
  }

  Future verifyCode(BuildContext context)async{
    final firebaseFirestore = FirebaseFirestore.instance.collection("users");
    if(otp.text.isEmpty){
      toast("Please enter the otp");
    }else if(otp.text.length < 6){
      toast("Please enter valid otp");
    }else{
      String token = await notificationServices.getDeviceToken();
      await firebaseAuth.signInWithCredential(PhoneAuthProvider.credential(verificationId: cameOtp, smsCode: otp.text)).then((value) {
        timer.cancel();
        if(value.additionalUserInfo!.isNewUser){
          firebaseFirestore.doc(value.user!.uid).set({
            "uid" : value.user!.uid,
            "phone" : value.user!.phoneNumber.reverse.substring(0,10).reverse,
            "profileImage" : "",
            "name" : "",
            "fcm_token" : token,
          });
        }else{
          firebaseFirestore.doc(value.user!.uid).update({
            "fcm_token" : token,
          });
        }

        onUserLogin();
        const AgreeAndContinueScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
      }).onError((error, stackTrace) {
        toast(error.toString());
      });
    }
    notifyListeners();
  }

  ValueNotifier<File?> imageFile = ValueNotifier(null);
  TextEditingController name = TextEditingController();
  bool _setupLoading = false;
  bool get setupLoading => _setupLoading;
  void changeSetupLoading(bool loading){
    _setupLoading = loading;
    notifyListeners();
  }
  void setupProfile(BuildContext context)async{
    if(name.text.isEmpty){
      Utils.showFlushBar(context, "Enter your name", MessageType.info);
      return;
    }
    changeSetupLoading(true);
    try{
      final auth = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance.collection("users");
      if(imageFile.value != null){
        String imgName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref("/userImages/$imgName");
        UploadTask uploadTask = ref.putFile(imageFile.value!);
        await Future.value(uploadTask);
        String url = await ref.getDownloadURL();
        await firestore.doc(auth!.uid).update({
          "name" : name.text,
          "profileImage" : url,
        }).then((value) {
          DashboardScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
          Utils.showFlushBar(context, "Success", MessageType.success);
        });
      }else{
        await firestore.doc(auth!.uid).update({
          "name" : name.text,
        }).then((value) {
          DashboardScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
          Utils.showFlushBar(context, "Success", MessageType.success);
        });
      }
    }catch(e){
      rethrow;
    }finally{
      changeSetupLoading(false);
    }
    notifyListeners();
  }

  void setupMyProfile(BuildContext context)async{
    if(name.text.isEmpty){
      Utils.showFlushBar(context, "Enter your name", MessageType.info);
      return;
    }
    changeSetupLoading(true);
    try{
      final auth = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance.collection("users");
      if(imageFile.value != null){
        String imgName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref("/userImages/$imgName");
        UploadTask uploadTask = ref.putFile(imageFile.value!);
        await Future.value(uploadTask);
        String url = await ref.getDownloadURL();
        await firestore.doc(auth!.uid).update({
          "name" : name.text,
          "profileImage" : url,
        }).then((value) {
          Utils.showFlushBar(context, "Success", MessageType.success);
        });
      }else{
        await firestore.doc(auth!.uid).update({
          "name" : name.text,
        }).then((value) {
          Utils.showFlushBar(context, "Success", MessageType.success);
        });
      }
    }catch(e){
      rethrow;
    }finally{
      changeSetupLoading(false);
    }
    notifyListeners();
  }
}