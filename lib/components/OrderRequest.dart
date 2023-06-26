import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/services/orderServcies.dart';

void showOrdersDialog(BuildContext context, OrderInfo order, ShopInfo shop) {
  OrderServices orderServices = OrderServices();

  showDialog(
    context: context,
    barrierDismissible: false,
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
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
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
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: order.location,
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(order.orderNo),
                        position: order.location,
                      ),
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Accept button action
                        // Implement your logic here
                        await orderServices.updateOrderStatus(
                            order, shop.uid, shop.phone, 'ongoing');
                        Navigator.pop(context);
                      },
                      child: Text('Accept'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.brown.shade700),
                      ),
                    ),
                    SizedBox(width: 40.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (order.shopUid != '') {
                          await orderServices.updateOrderStatus(
                              order, shop.uid, shop.phone, 'declined');
                        } else {
                          await orderServices.updateOrderStatus(
                              order, null, null, 'declined');
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Reject'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.red.shade400),
                      ),
                    ),
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
