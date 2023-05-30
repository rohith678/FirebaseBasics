import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/task.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void addTaskToDB(BuildContext context, Task task) async {
    await _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("tasks")
        .doc(task.id)
        .set(task.toJson())
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added successfully")));
    }).catchError((error) {
      debugPrint("Error in addData $error");
    });
  }

  Stream<List<Task>> getTasksStream() {
    return _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("tasks")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Task(
            title: document['title'],
            description: document['description'],
            id: document['id']);
      }).toList();
    });
  }

  void updateTask(BuildContext context, Task task) {
    _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("tasks")
        .doc(task.id)
        .update(task.toJson())
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Updated successfully")));
    }).catchError((error) {
      debugPrint("Error in updateData $error");
    });
  }

  void deleteTask(BuildContext context, Task task) {
    try {
      _db
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("tasks")
          .doc(task.id)
          .delete()
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Deleted successfully"))));
    } catch (error) {
      debugPrint("Error in deleteTask $error");
    }
  }

  Stream<List<Task>> serachByName(String name) {
    return _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("tasks")
        .where('title', isGreaterThanOrEqualTo: name)
        .where('title', isLessThanOrEqualTo: name)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Task(
            title: document['title'],
            description: document['description'],
            id: document['id']);
      }).toList();
    });
  }

  void uploadImage(XFile file) async {
    try {
      firebase_storage.UploadTask? uploadTask;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("images/")
          .child(_auth.currentUser!.uid)
          .child("/${file.name}");
      uploadTask = ref.putFile(File(file.path));
      firebase_storage.TaskSnapshot snapshot =
          await uploadTask.whenComplete(() => null);

      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageUrl = await ref.getDownloadURL();
        addImageDataToDB(imageUrl, file.name);
        debugPrint("ImageURL $imageUrl");
      } else {
        debugPrint('Error uploading image to Firebase Storage');
      }
    } catch (error) {
      debugPrint("error in uploadImage $error");
    }
  }

  void addImageDataToDB(String downloadURL, String fileName) async {
    await _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("images")
        .doc(fileName)
        .set({"imageURL": downloadURL, "imageName": fileName})
        .then((value) {})
        .catchError((error) {
          debugPrint("Error in addData $error");
        });
  }

  Stream<List<Map<String, String>>> getImageStream() {
    return _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("images")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return {
          "imageURL": document["imageURL"].toString(),
          "imageName": document["imageName"].toString()
        };
      }).toList();
    });
  }

  Future<void> deleteImageFromDB(String imageName) async {
    try {
      _db
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("images")
          .doc(imageName)
          .delete()
          .then((value) {
        deleteImageFromStorage(imageName);
      });
    } catch (error) {
      debugPrint("Error in deleteTask $error");
    }
  }

  void deleteImageFromStorage(String imageName) async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("images/")
        .child(_auth.currentUser!.uid)
        .child("/$imageName");
    try {
      await ref.delete();
    } catch (e) {
      debugPrint("Error in delete Image from Storage");
    }
  }
}
