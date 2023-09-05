import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/models/employeeModel.dart';

class OrderInfo {
  String uid;
  String orderNo;
  String status;
  String bikerUid;
  String? shopUid;
  String bikerName;
  num bikerPhone;
  num? shopPhone;
  String motorcycleNumber;
  String motorcycleType;
  String serviceRequired;
  LatLng location;
  num? pricingRating;
  num? serviceRating;
  DateTime creationTime;
  EmployeeUser assignedTo;

  OrderInfo({
    required this.uid,
    required this.orderNo,
    required this.status,
    required this.bikerUid,
    this.shopUid,
    required this.bikerName,
    required this.bikerPhone,
    required this.shopPhone,
    required this.motorcycleNumber,
    required this.motorcycleType,
    required this.serviceRequired,
    required this.location,
    this.pricingRating,
    this.serviceRating,
    required this.creationTime,
    required this.assignedTo,
  });

  factory OrderInfo.fromMap(Map<String, dynamic> map) {
    final latitude = map['location']['latitude'];
    final longitude = map['location']['longitude'];
    final Timestamp timestamp = map['creationTime'];
    final name = map["assignedTo"]["name"];
    final phone = map["assignedTo"]["phone"];
    final isActive = map["assignedTo"]["isActive"];

    return OrderInfo(
      uid: map['uid'],
      orderNo: map['orderNo'],
      status: map['status'],
      bikerUid: map['bikerUid'],
      shopUid: map.containsKey('shopUid') ? map['shopUid'] as String? : null,
      shopPhone: map.containsKey('shopPhone') ? map['shopPhone'] as num? : null,
      bikerName: map['bikerName'],
      bikerPhone: map['bikerPhone'],
      motorcycleNumber: map['motorcycleNumber'],
      motorcycleType: map['motorcycleType'],
      serviceRequired: map['serviceRequired'],
      location: LatLng(latitude, longitude),
      pricingRating: map.containsKey('pricingRating')
          ? map['pricingRating'] as num?
          : null,
      serviceRating: map.containsKey('serviceRating')
          ? map['serviceRating'] as num?
          : null,
      creationTime: timestamp.toDate(),
        assignedTo: EmployeeUser(name: name, phone: phone, isActive: isActive)
    );
  }
}
