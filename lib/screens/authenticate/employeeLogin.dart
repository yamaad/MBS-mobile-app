import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/loading.dart';

import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/components/customTextField.dart';

class EmployeeLogin extends StatefulWidget {
  @override
  State<EmployeeLogin> createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
  final AuthSevrices _auth = AuthSevrices();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  String ServerError = '';
  String phone = '';
  String otp = '';
  bool showOTPField = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text("Sign In as employee"),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
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
                        if (!showOTPField)
                          CustomTextField(
                            validator: (value) => value!.isEmpty
                                ? "Enter your phone number"
                                : null,
                            keyboardType: TextInputType.phone,
                            hintText: 'phone number',
                            onChanged: (value) =>
                                {setState(() => phone = value)},
                          ),
                        if (showOTPField) SizedBox(height: 20),
                        if (showOTPField)
                          CustomTextField(
                            validator: (value) => value!.isEmpty
                                ? "Enter your phone number"
                                : null,
                            keyboardType: TextInputType.phone,
                            hintText: 'OTP',
                            onChanged: (value) => {setState(() => otp = value)},
                          ),
                        if (!showOTPField)
                          TextButton(
                            onPressed: () async {
                              if (phone.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                String result =
                                    await _auth.employeeLogin(phone);
                                if (mounted) {
                                  setState(() {
                                    loading = false;
                                    if (result.isEmpty) {
                                      showOTPField = true;
                                    } else {
                                      ServerError = result;
                                    }
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (showOTPField)
                          ElevatedButton(
                            onPressed: () async {
                              if (otp.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                bool isLogedIn = await _auth.verfiyOtp(otp);
                                if (mounted) {
                                  setState(() {
                                    loading = false;
                                    showOTPField = false;
                                    Navigator.pop(context);
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
