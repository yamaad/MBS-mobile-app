import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/screens/client/dashBoardFunctions.dart';

void viewOrderDetails(BuildContext context, OrderInfo order) {
  showDialog(
    context: context,
    builder: (context) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order #${order.orderNo}'),
                Text(
                  '${order.status}',
                  style: TextStyle(
                      color: DashboardFunctions.orderStatusColor(order.status),
                      fontSize: 16.0),
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Name: "),
                    Spacer(),
                    Text(order.bikerName),
                  ],
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Brand: "),
                    Spacer(),
                    Text(order.motorcycleType),
                  ],
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Plate No: "),
                    Spacer(),
                    Text(order.motorcycleNumber),
                  ],
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Service required: "),
                    Spacer(),
                    Text(order.serviceRequired),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Text("Date: "),
                    Spacer(),
                    Text(order.creationTime.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
