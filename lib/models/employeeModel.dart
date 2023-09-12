import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmployeeUser {
  String name;
  String phone;
  bool isActive;
  LatLng location;
  EmployeeUser({
    required this.name,
    required this.phone,
    required this.isActive,
    required this.location,
  });

  factory EmployeeUser.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw Exception("Invalid user data");
    }
    final latitude = map['location']['latitude'];
    final longitude = map['location']['longitude'];

    return EmployeeUser(
      name: map['name'],
      phone: map['phone'],
      isActive: map['isActive'],
      location: LatLng(latitude, longitude),
    );
  }
}
