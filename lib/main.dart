import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:firebaseapp/authentication/otpscreen.dart';
import 'package:firebaseapp/authentication/phonenumber.dart';
import 'package:firebaseapp/pages/profile.dart';
import 'package:firebaseapp/welcomescreen.dart';

import 'authentication/userdetails.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => const WelcomeScreen(),
          "/home": (context) => const MyHomePage(),
          "/phone": (context) => const PhoneNumber(),
          "/otp": (context) => const OTPScreen(),
          "/profile": (context) => const Profile(),
          "/userDetails": (context) => const UserDetails(),
        },
        //./gradlew signingReport
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal, brightness: Brightness.dark)),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
