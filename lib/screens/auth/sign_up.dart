import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreith/screens/auth/login.dart';
import 'package:dreith/screens/profile/profile_page.dart';
import 'package:dreith/models/user_model.dart';
import 'package:dreith/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

Future<void> saveUserData(String username, String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('email', email);
}

class _SignUpState extends State<SignUp> {
  final _formkey = GlobalKey<FormState>();
  final _namecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  Future<void> signup() async {
    try {
      final auth_ = FirebaseAuth.instance;
      await auth_.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );
      // ✅ Save user data to SharedPreferences
      await saveUserData(
        _namecontroller.text.trim(),
        _emailcontroller.text.trim(),
      );
      await FirebaseFirestore.instance
       .collection('users')
   .doc(FirebaseAuth.instance.currentUser!.uid)
   .set({
     'name': _namecontroller.text.trim(),
     'email': _emailcontroller.text.trim(),
   }, SetOptions(merge: true));


      // ✅ Set user in Provider
      Provider.of<UserProvider>(context, listen: false).setUser(
        UserModel(
          name: _namecontroller.text.trim(),
          email: _emailcontroller.text.trim(),
        ),
      );
      // ✅ Navigate to profile or home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('registration succesfull')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).setUser(
      UserModel(name: _namecontroller.text, email: _emailcontroller.text),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _namecontroller,
                      decoration: InputDecoration(
                        hint: Text("Enter your name"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your name";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        hint: Text("Enter your email"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_'{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                            ).hasMatch(value)) {
                          return "Enter correct email";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      obscureText: true,
                      controller: _passwordcontroller,
                      decoration: InputDecoration(
                        hint: Text("Enter your password"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "enter correct password";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        signup();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.8,
                        MediaQuery.of(context).size.height * 0.07,
                      ),
                    ),
                    child: Text("Sign Up"),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text("Login", style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
