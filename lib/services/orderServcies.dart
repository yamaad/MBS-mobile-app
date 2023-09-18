import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/models/employeeModel.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
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
        'assignedTo': {
          "name": "",
          "phone": "",
          "isActive": false,
          "location": {
            "latitude": null,
            "longitude": null,
          }
        }
      };

      await orderDocRef.set(orderData);

      print('Order created successfully with ID: $orderId');
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  //update order status
  Future<void> updateOrderStatus(
      OrderInfo order, String? shopUid,
      num? shopPhone, String status, EmployeeUser? assignedEmployee) async {
    await ordersCollection.doc(order.uid).update({
      'status': shopUid != null ? status : "pending",
      'shopUid': shopUid != null ? shopUid : '',
      'shopPhone': shopPhone != null ? shopPhone : 0,
      'assignedTo': {
        "name": assignedEmployee != null
            ? assignedEmployee.name
            : order.assignedTo.name,
        "phone": assignedEmployee != null
            ? assignedEmployee.phone
            : order.assignedTo.phone,
        "isActive": assignedEmployee != null
            ? assignedEmployee.isActive
            : order.assignedTo.isActive,
        "location": {
          "latitude": assignedEmployee != null
              ? assignedEmployee.location!.latitude
              : order.assignedTo.location!.latitude,
          "longitude": assignedEmployee != null
              ? assignedEmployee.location!.longitude
              : order.assignedTo.location!.longitude,
        } 
      },
    });
  }
  Future<void> rateOrder(
      String orderUid, num pricingRating, num serviceRating,
      ShopInfo shop) async {
    await ordersCollection.doc(orderUid).update(
        {"pricingRating": pricingRating, "serviceRating": serviceRating});
    
    await FirebaseFirestore.instance.collection('user').doc(shop.uid).update({
      "pricing": (shop.pricing * shop.pricingCount + pricingRating) /
          (shop.pricingCount + 1),
      "pricingCount": shop.pricingCount + 1,
      "service": (shop.service * shop.serviceCount + serviceRating) /
          (shop.serviceCount + 1),
      "serviceCount": shop.serviceCount + 1
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
          .limit(5)
          .get();
    } else {
      data = await ordersCollection
          .where('shopUid', isEqualTo: currentUserUid)
          .orderBy('creationTime', descending: true)
          .limit(10)
          .get();
    }
    for (final doc in data.docs) {
      ordersHistory.add(OrderInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return ordersHistory;
  }

  Future<List<OrderInfo>> getCustOrdersHistory(String currentUserUid) async {
    QuerySnapshot data;

    data = await ordersCollection
        .where('bikerUid', isEqualTo: currentUserUid)
        .orderBy('creationTime', descending: true)
        .get();
    
    for (final doc in data.docs) {
      ordersHistory.add(OrderInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return ordersHistory;
  }

  Future<OrderInfo> getSingleOrder(String uid) async {
    final doc = await ordersCollection.doc(uid).get();
    final order = OrderInfo.fromMap(doc.data() as Map<String, dynamic>);
    return order;
  }

  Future<List<OrderInfo>> getOrderAssignedToMe(String phone) async {
    QuerySnapshot data;
    List<OrderInfo> orders = [];
    data = await ordersCollection
        .where('assignedTo.phone', isEqualTo: phone)
        .orderBy('creationTime', descending: true)
        .get();

    for (final doc in data.docs) {
      orders.add(OrderInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return orders;
  }
}
