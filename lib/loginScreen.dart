import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:port/homePage.dart';
import 'package:port/signupScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void LoginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      print("Fill all the fields");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          print("Successfully logged in");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (e) {
        print("$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          return Row(
            children: [
              // Left Side: Login Form
              Expanded(
                flex: isDesktop ? 1 : 2,
                child: Center(
                  child: Card(
                    elevation: 15,
                    child: Container(
                      width: isDesktop ? 400 : constraints.maxWidth * 0.9,
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color:  Color.fromARGB(255, 1, 6, 12),
                            ),
                          ),
                        const  SizedBox(height: 16.0),
                          const Text(
                            'Login to continue to your dashboard.',
                            style: TextStyle(
                              fontSize: 18.0,
                              color:  Color.fromARGB(255, 1, 6, 12),
                            ),
                          ),
                         const SizedBox(height: 32.0),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                         const SizedBox(height: 16.0),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: LoginUser,
                            style: ElevatedButton.styleFrom(
                              padding:const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: const Color.fromARGB(255, 1, 6, 12),
                            ),
                            child: const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpScreen()),
                              );
                            },
                            child:const Text(
                              "Create an Account!",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right Side: Slogan or Motivational Text
              if (isDesktop)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration:const  BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                           Color.fromARGB(255, 1, 6, 12),
                           Color.fromARGB(255, 65, 113, 153),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Unlock a World of Knowledge - Sign In to Share and Explore Notes!',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Your Ideas, Their Inspiration - Connect and Collaborate!',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
