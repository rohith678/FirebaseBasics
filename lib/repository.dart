import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebaseapp/task.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseRepository {
  final _db = FirebaseFirestore.instance;

  void addTaskToDB(BuildContext context, Task task) async {
    await _db.collection("tasks").doc(task.id).set(task.toJson()).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added successfully")));
    }).catchError((error) {
      debugPrint("Error in addData $error");
    });
  }

  Stream<List<Task>> getTasksStream() {
    return _db.collection("tasks").snapshots().map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Task(
            title: document['title'],
            description: document['description'],
            id: document['id']);
      }).toList();
    });
  }

  void updateTask(BuildContext context, Task task) {
    _db.collection("tasks").doc(task.id).update(task.toJson()).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Updated successfully")));
    }).catchError((error) {
      debugPrint("Error in updateData $error");
    });
  }

  void deleteTask(BuildContext context, Task task) {
    try {
      _db.collection("tasks").doc(task.id).delete().then((value) =>
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Deleted successfully"))));
    } catch (error) {
      debugPrint("Error in deleteTask $error");
    }
  }

  Stream<List<Task>> serachByName(String name) {
    return _db
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
          .child("images")
          .child("/${file.name}");
      uploadTask = ref.putFile(File(file.path));
      await uploadTask.whenComplete(() => null);
      String ImageURL = await ref.getDownloadURL();
      debugPrint("ImageURL $ImageURL");
    } catch (error) {
      debugPrint("error in uploadImage $error");
    }
  }
}
