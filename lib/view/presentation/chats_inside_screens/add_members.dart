import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/group_screen_provider.dart';
import 'package:qertsa/view/components/form_button.dart';
import 'package:qertsa/view/components/utils.dart';

class AddMembers extends StatelessWidget {
  final String groupId;
  final List<Contact> contacts;
  AddMembers({super.key, required this.groupId, required this.contacts});

  final groupList = FirebaseFirestore.instance.collection("groupList");
  @override
  Widget build(BuildContext context) {
    final groupScreenProvider = Provider.of<GroupScreenProvider>(context,listen: false);
    return Scaffold(
      appBar: appBarWidget(
        "Add Members",
        color: const Color(0xFF0C63EE),
        textColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder(
        stream: groupList.snapshots(),
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
            List data = snapshot.data!.docs.where((element) => element['groupId'] == groupId).toList();
          return Consumer<GroupScreenProvider>(
          builder: (context, value, child) {
            List<Contact> disabledContacts = value.contacts!.where((element) => data[0]['members'].toString().contains(element.phones![0].value.reverse.substring(0,10).reverse)).toList();
            return Form(
              key: value.formKey,
              child: Column(
                children: [
                  20.height,
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
                          hintStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black45
                          ),
                          padding: const EdgeInsets.only(right: 10),
                          disabledOptions: disabledContacts.map((e) => ValueItem(label: e.displayName!, value: e.phones![0].value.reverse.substring(0,10).reverse)).toList(),
                          onOptionSelected: (selectedOptions) {
                            if(selectedOptions.isNotEmpty){
                              value.groupMembers.value = data[0]['members'] +','+ selectedOptions.map((e) => e.value.toString()).toList().join(",");
                            }else{
                              value.groupMembers.value = data[0]['members'];
                            }
                          },
                          options: value.contacts!.map((e) => ValueItem(label: e.displayName!, value: e.phones![0].value.reverse.substring(0,10).reverse)).toList(),
                        ),
                      ],
                    ),
                  ),
                  20.height,
                  FormButton(
                    title: "Add",
                    loading: value.addMemberLoading,
                    onTap: () {
                      if(value.groupMembers.value == data[0]['members']){
                        Utils.showFlushBar(context, "Please select atleast one contact", MessageType.info);
                      }else{
                        if(value.formKey.currentState!.validate()){
                          groupScreenProvider.addMembers(context,groupId);
                        }
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
