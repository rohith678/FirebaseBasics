import 'dart:io';

import 'package:firebaseapp/repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Storage extends StatefulWidget {
  const Storage({super.key});

  @override
  State<Storage> createState() => _StorageState();
}

class _StorageState extends State<Storage> {
  String selectedFileName = '';
  XFile? file;
  FirebaseRepository repository = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Storage"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                repository.uploadImage(file!);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Uploaded successfully")));
                setState(() {
                  file = null;
                  selectedFileName = '';
                });
              },
              icon: const Icon(Icons.upload))
        ],
      ),
      body: Center(
        child: Container(
            height: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: selectedFileName.isEmpty
                ? const Text("Select Image")
                : SizedBox(
                    height: 200,
                    child: Image.file(File(file!.path)),
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Upload Image'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      GestureDetector(
                        child: const Text('Take a picture'),
                        onTap: () {
                          _pickImage(false);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        child: const Text('Select from gallery'),
                        onTap: () {
                          _pickImage(true);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickImage(bool imageFrom) async {
    file = await ImagePicker().pickImage(
        source: imageFrom ? ImageSource.gallery : ImageSource.camera);

    setState(() {
      selectedFileName = file!.name.toString();
    });
  }
}
