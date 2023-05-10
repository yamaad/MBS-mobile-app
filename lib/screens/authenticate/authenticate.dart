import 'package:flutter/material.dart';
import 'package:mbs_fyp/screens/authenticate/signin.dart';
import 'package:mbs_fyp/screens/authenticate/signup.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showRegisterPage = false;
  void toggleView() {
    setState(() {
      showRegisterPage = !showRegisterPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: showRegisterPage
          ? Signup(toggleView: toggleView)
          : Signin(toggleView: toggleView),
    );
  }
}
