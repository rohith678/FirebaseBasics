import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Column(children: [
        const Text("Welcome Screen"),
        ElevatedButton(
            onPressed: () async {
              if (authProvider.isSignedIn == true) {
                await authProvider
                    .getDataFromSharedPreferences()
                    .whenComplete(() {
                      Navigator.pushReplacementNamed(context, "/home");
                    });
                
              } else {
                Navigator.pushReplacementNamed(context, "/phone");
              }
            },
            child: const Text("Get Started"))
      ]),
    );
  }
}
