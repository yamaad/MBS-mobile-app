import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mbs_fyp/screens/authenticate/registeration/CustomerSignup.dart';
import 'package:mbs_fyp/screens/authenticate/registeration/clientRegisteration.dart';
import 'package:mbs_fyp/screens/authenticate/signin.dart';
import 'package:mbs_fyp/services/authService.dart';

class Authenticate extends StatefulWidget {

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  String _currentPage = 'signin';
  void _toggleView(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget pageToDisplay;
    switch (_currentPage) {
      case 'custReg':
        pageToDisplay = CustomerSignup(toggleView: _toggleView);
        break;
      case 'clientReg':
        pageToDisplay = ClientRegistration(toggleView: _toggleView);
        break;
      default:
        pageToDisplay = Signin(toggleView: _toggleView);
        break;
    }
    return pageToDisplay;
  }
}
