import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:firebaseapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otpCode = "";
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final verificationId = arguments["verificationId"];
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading == false
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("images/mobile2_bg.png"),
                      const SizedBox(
                        height: 16,
                      ),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary)),
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        onCompleted: (val) {
                          setState(() {
                            otpCode = val;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (otpCode != '') {
                              verifyOTP(context, verificationId, otpCode);
                            } else {
                              showSnackBar(context, "Enter 6 digit code");
                            }
                          },
                          child: const Text("Verify OTP")),
                      TextButton(
                          onPressed: () {},
                          child: const Text("Didnt receive code"))
                    ]),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.verifyOTP(context, verificationId, userOTP, () {
      //check whether user exists in DB
      authProvider.checkExistingUser().then((value) async {
        if (value == true) {
          //user exists
          authProvider.getDataFromFirestore().then((value) {
            authProvider.saveUserDataToSharedPreferences().then((value) {
              authProvider.setSignIn().then((value) {
                Navigator.pushReplacementNamed(context, "/home");
              });
            });
          });
        } else {
          //new user
          Navigator.pushReplacementNamed(context, "/userDetails");
        }
      });
    });
  }
}
