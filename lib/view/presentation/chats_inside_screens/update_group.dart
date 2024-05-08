import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/group_screen_provider.dart';
import 'package:qertsa/view/components/form_button.dart';
import 'package:qertsa/view/components/text_field_widget.dart';
import 'package:qertsa/view/components/utils.dart';

class UpdateGroup extends StatefulWidget {
  final String groupId;
  const UpdateGroup({super.key, required this.groupId});

  @override
  State<UpdateGroup> createState() => _UpdateGroupState();
}

class _UpdateGroupState extends State<UpdateGroup> {

  final groupsdata = FirebaseFirestore.instance.collection("groupList");
  late QuerySnapshot groupDataGet;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GroupScreenProvider>(context,listen: false).accessContacts();
    Provider.of<GroupScreenProvider>(context,listen: false).emptyCredentials();
    getGroupName();
  }

  void getGroupName()async{
    groupDataGet = await FirebaseFirestore.instance.collection("groupList").get();
    List groups = groupDataGet.docs.where((element) => element['groupId'] == widget.groupId).toList();
    Provider.of<GroupScreenProvider>(context,listen: false).groupName.text = groups[0]['name'];
    Provider.of<GroupScreenProvider>(context,listen: false).groupDesc.text = groups[0]['description'];
  }
  @override
  Widget build(BuildContext context) {
    final groupScreenProvider = Provider.of<GroupScreenProvider>(context,listen: false);
    return Scaffold(
      appBar: appBarWidget(
        "Update Group",
        color: const Color(0xFF0C63EE),
        textColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder(
        stream: groupsdata.snapshots(),
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
              child: Text("no data available"),
            );
          }
          List data = snapshot.data!.docs.where((element) => element['groupId'] == widget.groupId).toList();
          return Consumer<GroupScreenProvider>(
          builder: (context, value, child) {
            if(value.contacts == null){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Form(
              key: value.formKey,
              child: Column(
                children: [
                  20.height,
                  Stack(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: value.groupIcon,
                        builder: (context, groupIcon, child) {
                          return Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200
                            ),
                            child: ClipOval(
                              child: Center(
                                child: groupIcon == null ?
                                data[0]['groupIcon'].toString().isNotEmpty ?
                                Image.network(
                                  data[0]['groupIcon'],
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
                                      child: FaIcon(FontAwesomeIcons.users,color: Colors.grey,size: 40),
                                    );
                                  },
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  height:   double.infinity,
                                )
                                : FaIcon(FontAwesomeIcons.users,color: Colors.grey,size: 40):
                                Image.file(groupIcon,fit: BoxFit.fill,width: double.infinity,height: double.infinity,),
                              ),
                            ),
                          );
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
                                        value.groupIcon.value = image;
                                      });
                                    },
                                    title: Text("Camera",style: GoogleFonts.nunito()),
                                    leading: Icon(Icons.camera,color: Color(0xFF0C63EE)),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Utils.imagePicker(ImageSource.gallery,context).then((xFile){
                                        File image = File(xFile.path);
                                        value.groupIcon.value = image;
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
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0C63EE)
                            ),
                            child: Center(child: Icon(Icons.edit,color: Colors.white,size: 18)),
                          ),
                        ),
                      )
                    ],
                  ),
                  TextFieldWidget(
                    controller: value.groupName,
                    title: "Name",
                    hint: "Enter Group Name",
                    required: true,
                  ),
                  TextFieldWidget(
                    controller: value.groupDesc,
                    title: "Description",
                    hint: "Enter Group Description",
                    required: true,
                  ),
                  20.height,
                  FormButton(
                    title: "Update",
                    loading: value.createGroupLoading,
                    onTap: () {
                      if(value.formKey.currentState!.validate()){
                        groupScreenProvider.updateGroup(context,widget.groupId);
                      }
                    },
                  ),
                ],
              ),
            );
          },);
        },
      ),
    );
  }
}
