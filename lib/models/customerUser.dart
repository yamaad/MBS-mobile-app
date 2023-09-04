class CustomerUser {
  String firstName;
  String lastName;
  String email;
  String motorcycleNumber;
  String motorcycleType;
  int phone;
  String uid;

  CustomerUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.motorcycleNumber,
    required this.motorcycleType,
    required this.phone,
    required this.uid,
  });

  factory CustomerUser.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw Exception("Invalid user data");
    }

    return CustomerUser(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      motorcycleNumber: map['motorcycleNumber'],
      motorcycleType: map['motorcycleType'],
      phone: map['phone'],
    );
  }
}
