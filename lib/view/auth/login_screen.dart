import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/login_screen_provider.dart';
import 'package:qertsa/view/components/auth_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginScreenProvider = Provider.of<LoginScreenProvider>(context,listen: false);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 50,),
                Image.asset("assets/images/qertsa-logo.png",width: 150,),
              SizedBox(height: 30,),
              Text("Enter your Number to Get Started",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 19,fontWeight: FontWeight.bold),),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Confirm the County Code and Enter your Mobile Number",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(),),
                ),
                20.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 5)]),
                    child: Row(
                      children: [
                        CountryCodePicker(
                          textStyle: GoogleFonts.nunito(),
                          showFlag: false,
                          initialSelection: "IN",
                          onChanged: (value) {
                            loginScreenProvider.changeCountryCode(value.toString());
                          },
                          padding: EdgeInsets.zero,
                        ),
                        Container(
                          color: Colors.grey,
                          height: double.infinity,
                          width: 0.5,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: loginScreenProvider.phone,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.nunito(),
                            inputFormatters: [LengthLimitingTextInputFormatter(10)],
                            decoration: InputDecoration(
                                hintText: "Enter Mobile",
                                contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                border: OutlineInputBorder(borderSide: BorderSide.none)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                20.height,
                Consumer<LoginScreenProvider>(
                  builder: (context, value, child) {
                  return AuthButton(onTap: () {
                    loginScreenProvider.verifyPhoneNumber(context);
                  },
                    title: "Verify",
                    loading: value.loading,
                  );
                },)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
