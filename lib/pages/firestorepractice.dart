import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../repository.dart';
import '../task.dart';

class FireStorePractice extends StatefulWidget {
  const FireStorePractice({super.key});

  @override
  State<FireStorePractice> createState() => _FireStorePracticeState();
}

class _FireStorePracticeState extends State<FireStorePractice> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FirebaseRepository repository = FirebaseRepository();
  String updatedTitle = '', updatedDescription = '';

  @override
  Widget build(BuildContext context) {
    FirebaseRepository repository = FirebaseRepository();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("FireStore CRUD"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Task>>(
            stream: repository.getTasksStream(),
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
                            onTap: () {
                              handleOnTap(task);
                            },
                          ),
                          const Divider()
                        ],
                      );
                    });
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void handleOnTap(Task task) {
    setState(() {
      updatedDescription = task.description;
      updatedTitle = task.title;
    });
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Update Task",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                initialValue: task.title,
                onChanged: (val) {
                  setState(() {
                    updatedTitle = val;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Enter Title",
                    prefixIcon: const Icon(Icons.task),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                initialValue: task.description,
                onChanged: (val) {
                  setState(() {
                    updatedDescription = val;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Enter Description",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(
                height: 16,
              ),
            ]),
            actions: [
              TextButton(
                  onPressed: () {
                    repository.deleteTask(context, task);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete Task')),
              TextButton(
                  onPressed: () {
                    Task task1 = Task(
                        id: task.id,
                        title: updatedTitle,
                        description: updatedDescription);
                    repository.updateTask(context, task1);
                    Navigator.pop(context);
                  },
                  child: const Text('Edit Task'))
            ],
          );
        });
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add New Task",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                            hintText: "Enter Title",
                            prefixIcon: const Icon(Icons.task),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16))),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                            hintText: "Enter Description",
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16))),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            String taskId = generateTaskId();
                            Task task = Task(
                                title: titleController.text,
                                description: descriptionController.text,
                                id: taskId);
                            repository.addTaskToDB(context, task);
                            titleController.clear();
                            descriptionController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text('Add Task'))
                    ]),
              ));
        });
  }

  String generateTaskId() {
    var uuid = const Uuid();
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var random = (DateTime.now().microsecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');

    return '${uuid.v4()}_$timestamp$random';
  }
}
