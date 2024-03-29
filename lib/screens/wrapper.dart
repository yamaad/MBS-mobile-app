import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/loading.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/admin/adminInterface.dart';
import 'package:mbs_fyp/screens/authenticate/authenticate.dart';
import 'package:mbs_fyp/screens/client/dashbord.dart';
import 'package:mbs_fyp/screens/customer/customerHome.dart';
import 'package:mbs_fyp/screens/employee/employeeDashboard.dart';
import 'package:mbs_fyp/screens/inActiveUser.dart';
import 'package:mbs_fyp/screens/suspeneded.dart';
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
        future: services.getCurrentUserType(),
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
              return Dashboard(
                currentUserUid: user.uid,
              );
            } else if (userType == 'customer') {
              return CustomerHome();
            } else if (userType == 'suspend-customer' ||
                userType == 'suspend-client') {
              return SuspenededAccounts();
            } else if (userType == 'admin') {
              return AdminInterface();
            } else if (userType == 'inActive') {
              return InActiveUser();
            } else if (userType == "employee") {
              return EmployeeDashboard();
            } else {
              return Authenticate();
            }
          }
        },
      );
    } else {
      return Authenticate();
    }
  }
}
