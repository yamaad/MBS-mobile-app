import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/loading.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/authenticate/authenticate.dart';
import 'package:mbs_fyp/screens/home/customer/customerHome.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final AuthSevrices services;

  const Wrapper({required this.services});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MbsUser?>(context);
    if (user != null) {
      return FutureBuilder<String>(
        future: services.getUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for the result
            return Loading();
          } else if (snapshot.hasError) {
            // Show error message if an error occurred
            return Text('Error: ${snapshot.error}');
          } else {
            final userType = snapshot.data;
            if (userType == 'client') {
              return CustomerHome(); //! client!
            } else {
              return CustomerHome();
            }
          }
        },
      );
    } else {
      return Authenticate();
    }
  }
}
