import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formkey = GlobalKey<FormState>();

  final _emailcontroller = TextEditingController();

  Future<void> forgotPassword() async {
    final auth = FirebaseAuth.instance;
    final email = _emailcontroller.text.trim().toLowerCase();

    try {      
        await auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link sent to $email")),
        );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Forgot Password?', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _emailcontroller,
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(hint: Text("Enter your email")),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    forgotPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.8,
                    MediaQuery.of(context).size.height * 0.07,
                  ),
                ),
                child: Text("send link"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
