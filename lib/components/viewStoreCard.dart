import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  final String shopName;
  final num pricing;
  final int pricingCount;
  final num service;
  final int serviceCount;
  final String address;
  final onPress;

  const CustomCardWidget({
    Key? key,
    required this.shopName,
    required this.pricing,
    required this.service,
    required this.onPress,
    required this.pricingCount,
    required this.serviceCount,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: Text(
              shopName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "pricing " + pricing.toString(),
                      ),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                  Text(
                    pricingCount.toString() + " ratings",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("service " + service.toString()),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                  Text(
                    serviceCount.toString() + " ratings",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(address),
          SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: () {
                onPress();
              },
              child: Text('Make Order'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.brown),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
