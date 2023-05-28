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
        child: StreamBuilder<List<String>>(
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
                List<String> imagesList = snapshot.data ?? [];
                return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: imagesList.length,
                    itemBuilder: (context, index) {
                      String image = imagesList[index];
                      return GridTile(child: Image.network(image));
                    });
              }
            }),
      ),
    );
  }
}
