import 'package:flutter/material.dart';
import 'package:mbs_fyp/services/authService.dart';

class InActiveUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthSevrices _auth = AuthSevrices();
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
              "Your account yet to be approved by the admin, call +60196414375 for information"),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
            },
            child: Text("signout"),
          )
        ],
      ),
    );
  }
}
