import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mbs_fyp/models/validator.dart';
import 'package:mbs_fyp/services/authService.dart';

import '../../components/customTextField.dart';

class Signup extends StatefulWidget {
  final Function toggleView;
  const Signup({required this.toggleView});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final AuthSevrices _auth = AuthSevrices();
  final Validator _validate = Validator();
  final _formkey = GlobalKey<FormState>();
  String ServerError = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Register"),
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
                  CustomTextField(
                    validator: _validate.validateEmail,
                    hintText: 'email ',
                    onChanged: (value) => {setState(() => email = value)},
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    validator: (value) => _validate.validatePassword(value),
                    obscureText: true,
                    hintText: 'password',
                    onChanged: (value) => {setState(() => password = value)},
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    validator: (value) =>
                        value == password ? null : "Password doesn't match",
                    obscureText: true,
                    hintText: 'confirm password',
                    onChanged: (value) =>
                        {setState(() => confirmPassword = value)},
                  ),
                  Center(
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            widget.toggleView();
                          },
                          child: Text("Sign in"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        String result = await _auth.signUp(
                            email, password, confirmPassword);
                        setState(() {
                          ServerError = result;
                        });
                      }
                    },
                    child: Text('register'),
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
