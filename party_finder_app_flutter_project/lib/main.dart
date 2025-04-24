import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.7, // Adjust this value as needed (e.g., 0.8, 0.9)
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Image.asset("assets/images/masterOfDirtPicture.jpg"),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('Elevated Button Pressed!');
                // Add your button's action here
              },
              child: const Text('Elevated Button'),
            ),
          ],
        ),
      ),
    );
  }
}
