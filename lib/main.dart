import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  
Stripe.publishableKey =
      "pk_test_51NOZU2AUbAhm9TOtZrPMFPfu70M6yyawhykk61SsSsgNOlvmnA2ihYePNyJdvzUq3HPa9KQzV7AYMjXe7jS0L9VB00A7uRP4Yp";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MbsUser?>.value(
      value: AuthSevrices().user,
      initialData: null,
      child: MaterialApp(
        home: Wrapper(services: AuthSevrices()),
      ), 
    );
  }
}

