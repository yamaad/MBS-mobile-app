import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/loading.dart';
import 'package:mbs_fyp/models/validator.dart';
import 'package:mbs_fyp/services/authService.dart';

import '../../../components/customTextField.dart';

class CustomerSignup extends StatefulWidget {
  final toggleView;
  const CustomerSignup({required this.toggleView(String page)});

  @override
  State<CustomerSignup> createState() => _CustomerSignupState();
}

class _CustomerSignupState extends State<CustomerSignup> {
  final AuthSevrices _auth = AuthSevrices();
  final Validator _validate = Validator();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  String ServerError = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';
  int phone = 0;
  String motorcycleNumber = '';
  String motorcycleType = '';
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text("Register"),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                  child: Form(
                    key: _formkey,
                    child: ListView(
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
                              value!.isEmpty ? "Enter your First name" : null,
                          hintText: 'First name',
                          onChanged: (value) =>
                              {setState(() => firstName = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: (value) =>
                              value!.isEmpty ? "Enter your Last name" : null,
                          hintText: 'Last name',
                          onChanged: (value) =>
                              {setState(() => lastName = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? "Enter your phone number" : null,
                          hintText: 'phone number',
                          onChanged: (value) => {
                            if (value.isNotEmpty &&
                                value.contains(RegExp(r'^[0-9]+$')))
                              {
                                setState(() {
                                  phone = int.parse(value);
                                })
                              }
                          },
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: (value) => value!.isEmpty
                              ? "Enter your Motorcycle Type"
                              : null,
                          hintText: 'Motorcycle Type',
                          onChanged: (value) =>
                              {setState(() => motorcycleType = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: (value) =>
                              value!.isEmpty ? "Enter your plate number" : null,
                          hintText: 'plate number',
                          onChanged: (value) =>
                              {setState(() => motorcycleNumber = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: _validate.validateEmail,
                          hintText: 'email ',
                          onChanged: (value) => {setState(() => email = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: (value) =>
                              _validate.validatePassword(value),
                          obscureText: true,
                          hintText: 'password',
                          onChanged: (value) =>
                              {setState(() => password = value)},
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          validator: (value) => value == password
                              ? null
                              : "Password doesn't match",
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
                                  widget.toggleView("signin");

                                },
                                child: Text("Sign in"),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  widget.toggleView('clientReg');
                                },
                                child: Text("Register as a shop"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              String? result = await _auth.createCustUser(
                                  email,
                                  password,
                                  confirmPassword,
                                  "Maad",
                                  "Yasser",
                                  0196414375,
                                  "SM Sport",
                                  "JPM123");
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                  ServerError = result!;
                                });
                              }
                            }
                          },
                          child: Text('register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[
                                400], // change the background color of the button
                          ),
                        ),
                        SizedBox(height: 10),
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
