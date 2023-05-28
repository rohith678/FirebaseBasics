import 'package:country_picker/country_picker.dart';
import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:firebaseapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final phoneController = TextEditingController();
  Country country = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: "India",
      displayName: "India",
      displayNameNoCountryCode: "IN",
      e164Key: "");
  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length));
    return Scaffold(
      body: Padding(
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
                TextFormField(
                  cursorColor: Theme.of(context).colorScheme.primary,
                  controller: phoneController,
                  onChanged: (val) {
                    setState(() {
                      phoneController.text = val;
                    });
                  },
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                  bottomSheetHeight: 550),
                              onSelect: (val) {
                                setState(() {
                                  country = val;
                                });
                              });
                        },
                        child: Text(
                            "${country.flagEmoji} +${country.phoneCode}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    suffixIcon: phoneController.text.length == 10
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                    hintText: "Enter Phone Number",
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.black12)),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (phoneController.text.isEmpty) {
                        showSnackBar(context, "Phonenumber cannot be empty");
                      }
                      sendPhoneNumber();
                    },
                    child: const Text('Login'))
              ]),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    authProvider.signInWithPhone(context, "+${country.phoneCode}$phoneNumber");
  }
}
