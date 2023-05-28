import 'package:firebaseapp/repository.dart';
import 'package:flutter/material.dart';

import '../task.dart';

class FireStoreSearch extends StatefulWidget {
  const FireStoreSearch({super.key});

  @override
  State<FireStoreSearch> createState() => _FireStoreSearchState();
}

class _FireStoreSearchState extends State<FireStoreSearch> {
  String searchText = '';
  FirebaseRepository repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireStore Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextFormField(
              onChanged: (val) {
                setState(() {
                  searchText = val;
                });
              },
              decoration: InputDecoration(
                  hintText: "Search Title",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)))),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 100,
            child: StreamBuilder<List<Task>>(
              stream: repository.serachByName(searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<Task> taskList = snapshot.data ?? [];
                  return ListView.builder(
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        Task task = taskList[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.description),
                            ),
                            const Divider()
                          ],
                        );
                      });
                }
              },
            ),
          )
        ]),
      ),
    );
  }
}
