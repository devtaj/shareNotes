import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:port/loginScreen.dart';
// import 'package:port/profilePage.dart';

class DrawerHeaderScreen extends StatefulWidget {
  const DrawerHeaderScreen({super.key});

  @override
  State<DrawerHeaderScreen> createState() => _DrawerHeaderScreenState();
}

class _DrawerHeaderScreenState extends State<DrawerHeaderScreen> {
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    setState(() {
      // userName = user.displayName ?? "User Name"; // Fetch display name
      userEmail = user.email ?? "user@example.com"; // Fetch email
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName), // Display dynamic name
            accountEmail: Text(userEmail), // Display dynamic email
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context){
              //   return  NotesScreen();
              // }));
              // // Navigate to Profile Screen
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              // Navigate to Settings Screen
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              FirebaseAuth.instance.signOut(); // Sign out from Firebase
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return  LoginScreen();
              }));
            },
          ),
        ],
      ),
    );
  }
}
