import 'package:flutter/material.dart';

Widget buildGridView() {
  // Sample images
  final List<String> images = List.generate(
    9,
        (index) => ('assets/images/profile_picture.jpg'),
  );

  return GridView.builder(
    padding: const EdgeInsets.all(1.0),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 0.5,
      mainAxisSpacing: 0.5,
    ),
    itemCount: images.length,
    itemBuilder: (context, index) {
      return Image.asset(
        images[index],
        fit: BoxFit.cover,
      );
    },
  );
}
