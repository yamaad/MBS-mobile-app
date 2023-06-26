import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopInfo {
  final String uid;
  final String shopName;
  final String address;
  final LatLng location;
  final int phone;
  final List<String> services;
  final num service;
  final int serviceCount;
  final num pricing;
  final int pricingCount;
  bool status;

  ShopInfo({
    required this.uid,
    required this.shopName,
    required this.address,
    required this.location,
    required this.phone,
    required this.services,
    required this.service,
    required this.serviceCount,
    required this.pricing,
    required this.pricingCount,
    required this.status,
  });

  factory ShopInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw Exception("Invalid user data");
    }
    final location = LatLng(
      map['location']['latitude'],
      map['location']['longitude'],
    );

    return ShopInfo(
      uid: map['uid'],
      shopName: map['shopName'],
      address: map['address'],
      location: location,
      phone: map['phone'],
      services: (map['services'] as List<dynamic>?)?.cast<String>() ?? [],
      service: map['service'],
      serviceCount: map['serviceCount'],
      pricing: map['pricing'],
      pricingCount: map['pricingCount'],
      status: map["status"] as bool,
    );
  }
}
