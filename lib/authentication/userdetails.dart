import 'dart:io';

import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:firebaseapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modals/user.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.clear();
    bioController.clear();
    emailController.clear();
  }

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text("user Registration"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(children: [
                  InkWell(
                      onTap: () {
                        selectImage();
                      },
                      child: image == null
                          ? CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              radius: 50,
                              child: const Icon(
                                Icons.circle,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(image!),
                              radius: 50,
                            )),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        hintText: "Enter your name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bioController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        hintText: "Enter your bio",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () {
                        storeData();
                      },
                      child: const Text('sign up'))
                ]),
              ),
      ),
    );
  }

  void storeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    UserModal user = UserModal(
      name: nameController.text,
      email: emailController.text,
      bio: bioController.text,
      profilePic: "",
      phoneNumber: "",
      uid: "",
      createdAt: "",
    );
    if (image != null) {
      authProvider.saveUserDataToFirebase(context, user, image!, () {
        authProvider.saveUserDataToSharedPreferences().then((value) {
          authProvider.setSignIn().then((value) {
            Navigator.pushNamed(context, "/home");
          });
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload profile photo")));
    }
  }
}
