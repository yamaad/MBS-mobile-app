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
      final response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer ${apiKey}",
            "Content-type": "application/x-www-form-urlencoded"
          });
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
}
