import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/user.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignIn = false;
  bool _isLoading = false;
  String? _userId;
  UserModal? _userModal;
  UserModal get userModal => _userModal!;

  bool get isSignedIn => _isSignIn;
  bool get isLoading => _isLoading;
  String get getUserId => _userId!;

  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final FirebaseFirestore firebasefirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebasestorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isSignIn = sharedPreferences.getBool("is_signedIn") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool("is_signedIn", true);
    _isSignIn = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await firebaseauth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await firebaseauth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.pushNamed(context, "/otp",
                arguments: {"verificationId": verificationId});
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (exception) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP,
      Function onSuccess) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      User? user = (await firebaseauth.signInWithCredential(creds)).user;
      if (user != null) {
        _userId = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await firebasefirestore.collection("users").doc(_userId).get();

    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  void saveUserDataToFirebase(BuildContext context, UserModal user,
      File profilePic, Function onSuccess) async {
    _isLoading = true;
    notifyListeners();
    try {
      //upload image to firebase storage
      storeFileToStorage("profilepic/$_userId", profilePic).then((value) {
        user.profilePic = value;
        user.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        user.phoneNumber = firebaseauth.currentUser!.phoneNumber!;
        user.uid = firebaseauth.currentUser!.uid;
        firebasefirestore
            .collection("users")
            .doc(_userId)
            .set(user.toMap())
            .then((value) {
          onSuccess();
          _isLoading = false;
          notifyListeners();
        });
      });
      _userModal = user;

      //upload data to database
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = firebasestorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getDataFromFirestore() async {
    firebasefirestore
        .collection("users")
        .doc(firebaseauth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModal = UserModal(
          name: snapshot['name'],
          email: snapshot['email'],
          bio: snapshot['bio'],
          profilePic: snapshot['profilePic'],
          phoneNumber: snapshot['phoneNumber'],
          createdAt: snapshot['createdAt'],
          uid: snapshot['uid']);
    });
    _userId = userModal.uid;
  }

  //storing data locally
  Future saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        "user_modal", jsonEncode(userModal.toMap()));
  }

  //get data from sharedPreferences
  Future getDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString("user_model") ?? "";
    print("data $data");
    if (data != '') {
      _userModal = UserModal.fromMap(jsonDecode(data));
      _userId = _userModal!.uid;
      notifyListeners();
    }
  }

  Future signOut() async {
    await firebaseauth.signOut();
    _isSignIn = false;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
