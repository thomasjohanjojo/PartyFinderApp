import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before loading dotenv
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Load the environment variables
  await dotenv.load(fileName: ".env"); 
  
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