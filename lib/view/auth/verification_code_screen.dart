import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/login_screen_provider.dart';
import 'package:qertsa/view/components/auth_button.dart';

class VerificationCodeScreen extends StatelessWidget {
  VerificationCodeScreen({super.key});
  ValueNotifier<bool> verifyLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final loginScreenProvider = Provider.of<LoginScreenProvider>(context,listen: false);
    return WillPopScope(
      onWillPop: () async{
        loginScreenProvider.timer.cancel();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    50.height,
                    Image.asset("assets/images/qertsa-logo.png",width: 150,),
                    30.height,
                    Text("Verification Code",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 19,fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text("SMS Verification code has been Sent to",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(),),
                          SizedBox(height: 5,),
                          Text("${loginScreenProvider.countryCode} ${loginScreenProvider.phone.text}",style: GoogleFonts.nunito(color: Color(0xFF0C63EE),fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                    Pinput(
                      controller: loginScreenProvider.otp,
                      obscureText: true,
                      obscuringCharacter: "*",
                      length: 6,
                      defaultPinTheme: PinTheme(
                        height: 40,
                        width: 40,
                        textStyle: GoogleFonts.nunito(
                            fontSize: 25,
                            color: Color(0xFF0C63EE),
                            fontWeight: FontWeight.bold),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                              color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        height: 40,
                        width: 40,
                        textStyle: TextStyle(
                            fontSize: 25,
                            color: Color(0xFF0C63EE),
                            fontWeight: FontWeight.bold),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("I didn’t receive code.",style: GoogleFonts.nunito(color: Color(0xFF8D8D8D)),),
                        Consumer<LoginScreenProvider>(builder: (context, value, child) {
                          return value.timeLeft < 0?
                          InkWell(
                            onTap: () {
                              loginScreenProvider.timer.cancel();
                              loginScreenProvider.verifyPhoneNumber(context,resend: true);
                            },
                            child: Text("Resend Code",style: GoogleFonts.nunito(color: Color(0xFF0C63EE),fontWeight: FontWeight.bold),),
                          ):
                          Text(" ${value.timeLeft} sec left",style: GoogleFonts.nunito(),);
                        },)
                      ],
                    ),
                    20.height,
                    ValueListenableBuilder(
                      valueListenable: verifyLoading,
                      builder: (context, loading, child) {
                      return AuthButton(
                        loading: loading,
                        onTap: () {
                          verifyLoading.value = true;
                        loginScreenProvider.verifyCode(context).then((value){
                          verifyLoading.value = false;
                        }).onError((error, stackTrace){
                          verifyLoading.value = false;
                        });
                      }, title: "Verify Now",);
                    },)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
