import 'dart:io';

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

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GroupScreenProvider>(context,listen: false).accessContacts();
  }
  @override
  Widget build(BuildContext context) {
    final groupScreenProvider = Provider.of<GroupScreenProvider>(context,listen: false);
    return Scaffold(
      appBar: appBarWidget(
        "Create Group",
        color: const Color(0xFF0C63EE),
        textColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<GroupScreenProvider>(
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
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey
                      ),
                      child: ClipOval(
                        child: Center(
                          child: groupIcon == null ?
                          FaIcon(FontAwesomeIcons.user,color: Colors.white,size: 40):
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        5.width,
                        Text("Add members",style: GoogleFonts.nunito(fontWeight : FontWeight.w600)),
                      ],
                    ),
                    5.height,
                    MultiSelectDropDown(
                      borderWidth: 1,
                      hint: "Members",
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black45
                      ),
                      padding: EdgeInsets.only(right: 10),
                      onOptionSelected: (selectedOptions) {
                        value.groupMembers.value = selectedOptions.map((e) => e.value.toString()).toList().join(",");
                      },
                      options: value.contacts!.map((e) => ValueItem(label: e.displayName!, value: e.phones![0].value.reverse.substring(0,10).reverse)).toList().toSet().toList(),
                    ),
                  ],
                ),
              ),
              20.height,
              FormButton(
                title: "Create",
                loading: value.createGroupLoading,
                onTap: () {
                  if(value.formKey.currentState!.validate()){
                    groupScreenProvider.createGroup(context);
                  }
                },
              ),
            ],
          ),
        );
      },),
    );
  }
}
