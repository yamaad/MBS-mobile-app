import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/services/locationServeices.dart';
import 'package:mbs_fyp/models/orderInfo.dart';

class OrderServices {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final List<OrderInfo> ordersHistory = [];

  // stream orders for shops:
  Stream<List<OrderInfo>> streamPendingOrders() {
    return ordersCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('creationTime', descending: true)
        .limit(1)
        .snapshots()
        .map((QuerySnapshot<Object?> snapshot) {
      return snapshot.docs.map<OrderInfo>((DocumentSnapshot<Object?> doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderInfo.fromMap(data);
      }).toList();
    });
  }

  //biker creates Order:
  Future<void> createOrder(CustomerUser biker, String? shopUid, String service,
      num? shopPhone) async {
    Position location = await LocationServices.getCurrentLocation();
    try {
      final orderDocRef =
          ordersCollection.doc(); // Create a new document with generated ID
      final orderId = orderDocRef.id;

      final orderData = {
        'uid': orderId,
        'status': 'pending',
        'bikerUid': biker.uid,
        'shopUid': shopUid != null ? shopUid : '',
        'shopPhone': shopPhone != null ? shopPhone : 0,
        'bikerName': '${biker.firstName} ${biker.lastName}',
        'bikerPhone': biker.phone,
        'motorcycleNumber': biker.motorcycleNumber,
        'motorcycleType': biker.motorcycleType,
        'serviceRequired': service,
        'orderNo': orderId.substring(0, 6),
        'location': {
          "latitude": location.latitude,
          "longitude": location.longitude,
        },
        'creationTime': DateTime.now(),
      };

      await orderDocRef.set(orderData);

      print('Order created successfully with ID: $orderId');
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  //update order status
  Future<void> updateOrderStatus(
      OrderInfo order, String? shopUid, num? shopPhone, String status) async {
    await ordersCollection.doc(order.uid).update({
      'status': shopUid != null ? status : "pending",
      'shopUid': shopUid != null ? shopUid : '',
      'shopPhone': shopPhone != null ? shopPhone : 0,
    });
  }

  // Return the latest 5 Orders in the history
  Future<List<OrderInfo>> getOrdersHistory(String currentUserUid) async {
    QuerySnapshot data;
    if (ordersHistory.isNotEmpty) {
      data = await ordersCollection
          .where('shopUid', isEqualTo: currentUserUid)
          .orderBy('creationTime', descending: true)
          .where('creationTime', isLessThan: ordersHistory.last.creationTime)
          .limit(3)
          .get();
    } else {
      data = await ordersCollection
          .where('shopUid', isEqualTo: currentUserUid)
          .orderBy('creationTime', descending: true)
          .limit(3)
          .get();
    }
    for (final doc in data.docs) {
      ordersHistory.add(OrderInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return ordersHistory;
  }
}
