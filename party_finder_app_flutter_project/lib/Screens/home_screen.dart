import 'package:flutter/material.dart';
import 'package:party_finder_app_flutter_project/Screens/upload_picture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UploadPictureWidget()),
              );
            },
            child: Text("Upload a poster")),
        const SizedBox(height: 20), // For a nice gap
        ElevatedButton(
          onPressed: () {},
          child: Text("Show List"),
        )
      ],
    ));
  }
}
