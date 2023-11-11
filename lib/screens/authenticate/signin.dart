import 'package:flutter/material.dart';
import 'package:mbs_fyp/screens/authenticate/employeeLogin.dart';

import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/components/customTextField.dart';

import '../../components/loading.dart';

class Signin extends StatefulWidget {
  final Function toggleView;
  const Signin({required this.toggleView});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final AuthSevrices _auth = AuthSevrices();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  String ServerError = '';
  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Sign In"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                        Text(
                          "MB SERVICES",
                          style: TextStyle(
                            fontSize: 24.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Make the text bold
                            color: Colors.blue, // Set the text color
                            // You can also add more styling like fontFamily, letterSpacing, etc.
                          ),
                        ),
                  CustomTextField(
                    validator: (value) =>
                        value!.isEmpty ? "Enter your email" : null,
                    hintText: 'email ',
                    onChanged: (value) => {setState(() => email = value)},
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    validator: (value) =>
                        value!.isEmpty ? "Enter your password" : null,
                    obscureText: true,
                    hintText: 'password',
                    onChanged: (value) => {setState(() => password = value)},
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                                widget.toggleView('custReg');
                        },
                        child: Text("register"),
                      ),
                      Spacer(),
                      TextButton(
                              onPressed: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EmployeeLogin()));
                              },
                              child: Text("login as employee"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                        String result = await _auth.signIn(email, password);
                              if (mounted) {
                                setState(() {

                                loading = false;
                          ServerError = result;
                                });
                              }
                      }
                    },
                    child: Text('log in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[
                          400], // change the background color of the button
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ServerError,
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
