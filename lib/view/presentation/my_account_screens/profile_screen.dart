import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/login_screen_provider.dart';
import 'package:qertsa/view/components/auth_button.dart';
import 'package:qertsa/view/components/utils.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final auth = FirebaseAuth.instance.currentUser;
  final userData = FirebaseFirestore.instance.collection("users");
  @override
  Widget build(BuildContext context) {
    final loginScreenProvider = Provider.of<LoginScreenProvider>(context,listen: false);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: userData.snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(snapshot.hasError){
              return const Center(
                child: Text("something went wrong"),
              );
            }
            if(!snapshot.hasData){
              return const Center(
                child: Text("No data available"),
              );
            }
            List data = snapshot.data!.docs.where((element) => element['uid'] == auth!.uid).toList();
            loginScreenProvider.name.text = data[0]['name'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Column(
                children: [
                  50.height,
                  Text(
                    "Set Up Your Info",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      Consumer<LoginScreenProvider>(
                        builder: (context, value, child) {
                          return ValueListenableBuilder(
                            valueListenable: value.imageFile,
                            builder: (context, imageFile, child) {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: ClipOval(
                                  child: imageFile == null
                                      ? Image.network(
                                    data[0]['profileImage'],
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if(loadingProgress == null){
                                        return child;
                                      }
                                      return SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null ?
                                          loadingProgress.cumulativeBytesLoaded/
                                              loadingProgress.expectedTotalBytes!: null,
                                          strokeWidth: 3,
                                          color: Colors.purple,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: FaIcon(FontAwesomeIcons.user,color: Colors.white,size: 30),
                                      );
                                    },
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height:   double.infinity,
                                  )
                                      : Image.file(imageFile,fit: BoxFit.fill,height: double.infinity,width: double.infinity),
                                ),
                              );
                            },);
                        },),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                showDragHandle: true,
                                context: context, builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Utils.imagePicker(ImageSource.camera,context).then((xFile){
                                          File image = File(xFile.path);
                                          loginScreenProvider.imageFile.value = image;
                                        });
                                      },
                                      title: Text("Camera",style: GoogleFonts.nunito()),
                                      leading: Icon(Icons.camera,color: Color(0xFF0C63EE)),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        Utils.imagePicker(ImageSource.gallery,context).then((xFile){
                                          File image = File(xFile.path);
                                          loginScreenProvider.imageFile.value = image;
                                        });
                                      },
                                      title: Text("Gallery",style: GoogleFonts.nunito(),),
                                      leading: Icon(Icons.browse_gallery,color: Color(0xFF0C63EE),),
                                    )
                                  ],
                                );
                              },);
                            },
                            child: Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 17,
                                )),
                          ))
                    ],
                  ),
                  30.height,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                    ),
                    child: Consumer<LoginScreenProvider>(
                      builder: (context, value, child) {
                        return TextFormField(
                          controller: loginScreenProvider.name,
                          style: GoogleFonts.nunito(),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              hintText: "Enter Name",
                              border: OutlineInputBorder(borderSide: BorderSide.none)),
                        );
                      },),
                  ),
                  20.height,
                  Consumer<LoginScreenProvider>(builder: (context, value, child) {
                    return AuthButton(
                      onTap: () {
                        loginScreenProvider.setupMyProfile(context);
                      },
                      title: "Save & Continue",
                      loading: value.setupLoading,
                    );
                  },),
                ],
              ),
            );
          },),
      ),
    );
  }
}
