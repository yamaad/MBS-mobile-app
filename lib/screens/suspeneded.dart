import 'package:flutter/material.dart';
import 'package:mbs_fyp/services/authService.dart';

class SuspenededAccounts extends StatelessWidget {
  const SuspenededAccounts({super.key});
  @override
  Widget build(BuildContext context) {
AuthSevrices _auth = AuthSevrices();
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
              "This account has been Suspended, you can not use our services until the current issue is resolved. call +60196414375 for information"),
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
