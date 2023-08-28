import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentServices {
  final apiKey = dotenv.env['STRIPE_API_KEY'] ?? '';
  Map<String, dynamic>? paymentIntent;

  Future<bool> createPaymentInent() async {
    try {
      Map<String, dynamic> body = {"amount": "20000", "currency": "MYR"};
      print("***************");
      final response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer ${apiKey}",
            "Content-type": "application/x-www-form-urlencoded"
          });
      print(response.body);
      print("***************");
      paymentIntent = json.decode(response.body);
    } catch (e) {
      throw Exception(e);
    }
    await Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntent!['client_secret'],
                style: ThemeMode.light,
                merchantDisplayName: "MBK services"))
        .then((value) => {});
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((value) => {print("payment success")});
      return true;
    } catch (e) {
      print("***error***");
      print(e);
      print("***error***");
      return false;
    }
  }

  // Future<bool> collectCardDetails() async {
  //   try {
  //     // Show the CardField UI for collecting payment details
  //     PaymentMethod paymentMethod =
  //         await StripePayment.paymentRequestWithCardForm(
  //             CardFormPaymentRequest());

  //     // Process the paymentMethod and create a PaymentIntent on your server

  //     // If payment is successful, return true
  //     return true;
  //   } catch (error) {
  //     // Handle errors during payment process
  //     print('Payment Error: $error');
  //     return false;
  //   }
  // }

  // Future<void> createPaymentMethod() async {
  //   StripePayment.setStripeAccount("");
  //   final amount = 50;
  //   print('amount in pence/cent which will be charged = $amount');
  //   //step 1: add card
  //   PaymentMethod paymentMethod = PaymentMethod();
  //   paymentMethod = await StripePayment.paymentRequestWithCardForm(
  //     CardFormPaymentRequest(),
  //   ).then((PaymentMethod paymentMethod) {
  //     return paymentMethod;
  //   }).catchError((e) {
  //     print('Errore Card: ${e.toString()}');
  //   });
  // }
}
