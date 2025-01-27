import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:port/homePage.dart';
import 'package:port/loginScreen.dart';
// import 'package:port/signupScreen.dart';
// import 'package:port/uploadbutton.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyA1yeryvWjA00WtF_DhGNHJO95NAKdlQT8",
    appId: "1:853406348511:android:1eac6c451faa34450a256a",
    messagingSenderId: "853406348511",
    projectId: "note-3b199",
  ),
);
  runApp(const NotesSharingPlatform());
}

class NotesSharingPlatform extends StatelessWidget {
  const NotesSharingPlatform({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes Sharing Platform',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: (FirebaseAuth.instance.currentUser !=null)? const HomePage() : LoginScreen(),
    );
  }
}

