import 'package:flutter/material.dart';

class SuspenededAccounts extends StatelessWidget {
  const SuspenededAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
          "This account has been Suspended, you can not use our services until the current issue is resolved. call +60196414375 for information"),
    );
  }
}
