import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  num? rating;
  DateTime creationTime;

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
    this.rating,
    required this.creationTime,
  });

  factory OrderInfo.fromMap(Map<String, dynamic> map) {
    final latitude = map['location']['latitude'];
    final longitude = map['location']['longitude'];
    final Timestamp timestamp = map['creationTime'];

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
      rating: map.containsKey('rating') ? map['rating'] as num? : null,
      creationTime: timestamp.toDate(),
    );
  }
}
