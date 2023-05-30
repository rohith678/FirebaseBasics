import 'package:flutter/material.dart';

import '../repository.dart';

class Images extends StatefulWidget {
  const Images({super.key});

  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  @override
  Widget build(BuildContext context) {
    FirebaseRepository repository = FirebaseRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Map<String, String>>>(
            stream: repository.getImageStream(),
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
                List<Map<String, String>> imagesList = snapshot.data ?? [];
                return imagesList.isEmpty
                    ? const Center(
                        child: Text("No images "),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: imagesList.length,
                        itemBuilder: (context, index) {
                          Map<String, String> imageMap = imagesList[index];
                          return GestureDetector(
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            "Are you sure to delete image"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('No')),
                                          TextButton(
                                              onPressed: () {
                                                repository
                                                    .deleteImageFromDB(
                                                        imageMap["imageName"]
                                                            as String)
                                                    .then((value) {});
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Yes')),
                                        ],
                                      );
                                    });
                              },
                              child: GridTile(
                                  child: Image.network(
                                      imageMap["imageURL"] as String)));
                        });
              }
            }),
      ),
    );
  }
}
