import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/loading.dart';
import 'package:mbs_fyp/models/validator.dart';
import 'package:mbs_fyp/services/authService.dart';

import '../../../components/customTextField.dart';
import '../../../services/locationServeices.dart';

class ClientRegistration extends StatefulWidget {
  final Function toggleView;
  const ClientRegistration({required this.toggleView});

  @override
  State<ClientRegistration> createState() => _ClientRegistrationState();
}

class _ClientRegistrationState extends State<ClientRegistration> {
  final AuthSevrices _auth = AuthSevrices();
  final LocationServices _locationServices = LocationServices();

  final Validator _validate = Validator();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  String serverError = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String shopName = '';
  String ownerName = '';
  int phone = 0;
  List<String> addresses = [];
  String address = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text("Register as a shop"),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
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
                            value!.isEmpty ? "Enter your shop name" : null,
                        hintText: 'shop name',
                        onChanged: (value) => setState(() => shopName = value),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter owner full name" : null,
                        hintText: 'owner full name',
                        onChanged: (value) => setState(() => ownerName = value),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value!.isEmpty ? "Enter shop phone number" : null,
                        hintText: 'phone number',
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              value.contains(RegExp(r'^[0-9]+$'))) {
                            setState(() {
                              phone = int.parse(value);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Text(
                            'Address:', // Add your hint text here
                          ),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) async {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              addresses = await _locationServices
                                  .searchPlaces(textEditingValue.text);

                              return addresses;
                            },
                            onSelected: (String selection) {
                              setState(() {
                                address = selection;
                              });
                            },
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        validator: _validate.validateEmail,
                        hintText: 'email ',
                        onChanged: (value) => setState(() => email = value),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        validator: (value) => _validate.validatePassword(value),
                        obscureText: true,
                        hintText: 'password',
                        onChanged: (value) => setState(() => password = value),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        validator: (value) =>
                            value == password ? null : "Password doesn't match",
                        obscureText: true,
                        hintText: 'confirm password',
                        onChanged: (value) =>
                            setState(() => confirmPassword = value),
                      ),
                      Center(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                widget.toggleView('');
                              },
                              child: Text("Sign in"),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () async {
                                widget.toggleView('custReg');
                              },
                              child: Text("customer Sign up"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });

                            String result = await _auth.createClientUser(
                                email,
                                password,
                                confirmPassword,
                                shopName,
                                ownerName,
                                phone,
                                address);

                            if (mounted) {
                              setState(() {
                                loading = false;
                                serverError = result;
                              });
                            }
                          }
                        },
                        child: Text('register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        serverError,
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
