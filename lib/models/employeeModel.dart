class EmployeeUser {
  String name;
  String phone;
  bool isActive;

  EmployeeUser({
    required this.name,
    required this.phone,
    required this.isActive,
  });

  factory EmployeeUser.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw Exception("Invalid user data");
    }

    return EmployeeUser(
      name: map['name'],
      phone: map['phone'],
      isActive: map['isActive'],
    );
  }
}
