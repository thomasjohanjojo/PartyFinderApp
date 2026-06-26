import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () {}, child: Text("Upload a poster")),
        const SizedBox(height: 20), // For a nice gap
        ElevatedButton(
          onPressed: () {},
          child: Text("Show List"),
        )
      ],
    ));
  }
}
