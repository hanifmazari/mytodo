import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mytodo/config/config.dart';
import 'package:mytodo/screens/homeScreen.dart';
import 'package:mytodo/screens/loginScree.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
            color: Colors.blue,
          );
        }

        // Once complete, show your application

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomePage(),
            theme: ThemeData(
                primaryColor: primaryColor, brightness: Brightness.light),
            darkTheme: ThemeData(
                brightness: Brightness.dark, primaryColor: Color(0xFF00F58D)),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  @override

  // final FirebaseAuth auth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null
        ? LoginScreen()
        : HomeScreen();
  }
}
