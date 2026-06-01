import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PartyFinderApp());
}

class PartyFinderApp extends StatelessWidget {
  const PartyFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Party Finder',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}