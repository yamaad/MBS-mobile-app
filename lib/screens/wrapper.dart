import 'package:flutter/src/widgets/framework.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/authenticate/authenticate.dart';
import 'package:mbs_fyp/screens/home/customer/customerHome.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MbsUser?>(context);
    return user != null ? CustomerHome() : Authenticate();
  }
}
