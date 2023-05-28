import 'package:firebaseapp/authentication/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                authProvider.signOut().then((value) {
                  Navigator.pushNamed(context, "/");
                });
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: NetworkImage(authProvider.userModal.profilePic),
              radius: 50,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(authProvider.userModal.name),
            Text(authProvider.userModal.email),
            Text(authProvider.userModal.phoneNumber),
            Text(authProvider.userModal.bio),
          ])),
    );
  }
}
