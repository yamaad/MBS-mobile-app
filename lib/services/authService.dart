import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/models/employeeModel.dart';
import '../models/shopInfo.dart';
import '../models/user.dart';
import 'locationServeices.dart';

class AuthSevrices {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<EmployeeUser> employees = [];
  QueryDocumentSnapshot? lastDocument;
  var verificationId = ''.obs;

  // create user obj based on firebase user
  MbsUser? _userFromFirebaseUser(User? user) {
    if (user != null) {
      return MbsUser(uid: user.uid);
    }
    return null;
  }

  // listen to auth change
  Stream<MbsUser?> get user {
    return FirebaseAuth.instance
        .userChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  // create client user
  Future createClientUser(
    final email,
    final password,
    final confirmPassword,
    final shopName,
    final ownerName,
    int phone,
    final address,
  ) async {
    if (password == confirmPassword) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final location = await LocationServices.getLatLngFromAddress(address);
        await db.collection("user").doc(credential.user!.uid).set({
          "uid": credential.user!.uid,
          "shopName": shopName,
          "ownerName": ownerName,
          "phone": phone,
          "email": email,
          "address": address,
          "location": {
            "latitude": location.latitude,
            "longitude": location.longitude,
          },
          "userType": "client",
          "isActive": false,
          "services": [],
          "pricing": 5.0,
          "pricingCount": 0,
          "service": 5.0,
          "serviceCount": 0,
          "status": false,
        });
        await db
            .collection("brands")
            .doc(credential.user!.uid)
            .set({"brands": []});
        return '';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print(e);
          return 'The account already exists for that email.';
        }
      } catch (e) {
        print("***** ERROR *****");
        print(e);
        print("***** ERROR *****");
        return e.toString();
      }
    } else {
      print("***** ERROR *****");
      print("password doesn't match");
      print("***** ERROR *****");
      return "password doesn't match";
    }
  }

  // create customer user
  Future createCustUser(
      final email,
      final password,
      final confirmPassword,
      final firstName,
      final lastName,
      int phone,
      final motorcycleType,
      final motorcycleNumber) async {
    if (password == confirmPassword) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await db.collection("user").doc(credential.user!.uid).set({
          "uid": credential.user!.uid,
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "email": email,
          "motorcycleType": motorcycleType,
          "motorcycleNumber": motorcycleNumber,
          "userType": "customer",
          "isActive": true,
        });

        return '';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return 'The account already exists for that email.';
        }
      } catch (e) {
        return e.toString();
      }
    } else {
      return "password doesn't match";
    }
  }

//
  Future<String> createEmployee(String name, String phone) async {
    if (phone.startsWith("0")) {
      phone = "+6" + phone;
    } else if (phone.startsWith("6")) {
      phone = "+" + phone;
    }

    final user = FirebaseAuth.instance.currentUser;
    final regiseredUser = await db
        .collection("employees")
        .doc(user!.uid)
        .collection("employee")
        .doc(phone)
        .get();
    if (regiseredUser.exists) {
      final activeUser = await db
          .collection("employees")
          .doc(user.uid)
          .collection("employee")
          .where("phone", isEqualTo: phone)
          .where("isActive", isEqualTo: false)
          .get();
      if (activeUser.docs.isNotEmpty) {
        await db
            .collection("employees")
            .doc(user.uid)
            .collection("employee")
            .doc(phone)
            .update({"isActive": true});
        employees.clear();
        await this.getEmployees();
        return "employee user re-activated";
      } else {
        return "employee exsits already";
      }
    } else {
      try {
        await db
            .collection("employees")
            .doc(user.uid)
            .collection("employee")
            .doc(phone)
            .set({
          "name": name,
          "phone": phone,
          "isActive": true,
          "location": {"latitude:": 0.1, "longitude:": 0.1}
        });
        employees.clear();
        await this.getEmployees();
        return "employee user created";
      } catch (e) {
        print(e);
        return "invalid input";
      }
    }
  }

  Future<List<EmployeeUser>> getEmployees() async {
    QuerySnapshot data;
    final user = FirebaseAuth.instance.currentUser;
    if (employees.isNotEmpty) {
      data = await db
          .collection("employees")
          .doc(user!.uid)
          .collection("employee")
          .where('isActive', isEqualTo: true)
          .orderBy('name', descending: false)
          .startAfter([lastDocument!])
          .limit(5)
          .get();
    } else {
      data = await db
          .collection("employees")
          .doc(user!.uid)
          .collection("employee")
          .where('isActive', isEqualTo: true)
          .orderBy('name', descending: false)
          .limit(10)
          .get();
    }
    if (data.docs.isNotEmpty) {
      lastDocument = data.docs[data.docs.length - 1];
      for (final doc in data.docs) {
        employees.add(EmployeeUser.fromMap(doc.data() as Map<String, dynamic>));
      }
    }
    return employees;
  }

  Future deActiveEmployee(String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    await db
        .collection("employees")
        .doc(user!.uid)
        .collection('employee')
        .doc(phone)
        .update({"isActive": false});
    final employeesIndex =
        employees.indexWhere((element) => element.phone == phone);
   
    employees.removeAt(employeesIndex);
  }

  // sign in
  Future signIn(final emailAddress, final password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return '';
    } catch (e) {
      return "invalid login";
    }
  }

  // sign out
  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> getCurrentUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("user").doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        if (doc.get('userType') == "client") {
          if (!doc.get("isActive")) {
            return "inActive";
          }
          return doc.get('userType');
        } else
          return doc.get('userType');
      }
      return "employee";
    }
    return "No user logged in";
  }

  Future<List<ShopInfo>> getClientUsers() async {
    final userType = 'client';
    final docRef = db.collection('user');

    final snapshot = await docRef
        .where('userType', isEqualTo: userType)
        .where('status', isEqualTo: true)
        .get();

    List<ShopInfo> userList = [];
    snapshot.docs.forEach((doc) {
      final shopInfo = ShopInfo.fromMap(doc.data());
      userList.add(shopInfo);
    });
    userList = await LocationServices.sortShopList(userList);
    return userList;
  }

  Future<CustomerUser> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("user").doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        // Extract the user data from the document
        final userData = CustomerUser.fromMap(doc.data());
        return userData;
      }
      throw Exception("User not found");
    }
    throw Exception("No user logged in");
  }

  Future<ShopInfo> getCurrentShopData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("user").doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        // Extract the user data from the document
        final userData = ShopInfo.fromMap(doc.data());
        return userData;
      }
      throw Exception("User not found");
    }
    throw Exception("No user logged in");
  }

  Future<String> getUserType(String uid) async {
    final docRef = db.collection("user").doc(uid);
    final doc = await docRef.get();
    if (doc.exists) {
      return doc.get('userType');
    } else
      return "User not found";
  }

  Future<ShopInfo> getShopData(String uid) async {
    final docRef = db.collection("user").doc(uid);
    final doc = await docRef.get();
    final userData = ShopInfo.fromMap(doc.data());
    return userData;
  }

  Future<CustomerUser> getBikerData(String uid) async {
    final docRef = db.collection("user").doc(uid);
    final doc = await docRef.get();
    // Extract the user data from the document
    final userData = CustomerUser.fromMap(doc.data());
    return userData;
  }

  Future updateCustomerInfo(
      int phone, final motorcycleType, final motorcycleNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("user").doc(user.uid);
      await docRef.update({
        'phone': phone,
        'motorcycleNumber': motorcycleNumber,
        'motorcycleType': motorcycleType
      });
    }
  }

  Future<dynamic> getBikerInfo(final fieldName) async {
    final user = FirebaseAuth.instance.currentUser;
    dynamic fieldValue;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      fieldValue = snapshot[fieldName];
      return fieldValue;
    }

    return null;
  }

  Future<List<dynamic>> getAvaiableBrands() async {
    final user = FirebaseAuth.instance.currentUser;
    List<dynamic> availableBrands = [];
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('brands')
          .doc(user.uid)
          .get();
      availableBrands = snapshot["brands"];
    }
    return availableBrands;
  }

  Future addBrand(List<dynamic> brands) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("brands").doc(user.uid);
      await docRef.set({
        'brands': brands,
      });
    }
  }

  Future<bool> verfiyOtp(String otp) async {
    final credential = await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: this.verificationId.value, smsCode: otp));
    return credential.user != null ? true : false;
  }

  Future phoneAuthentication(String phone) async {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+60196414375",
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          print(e);
          // Get.snackbar("error", e.code);
        },
        codeSent: (verificationId, resendToken) {
          this.verificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          this.verificationId.value = verificationId;
        });
  }

  Future<EmployeeUser?> getCurrentEmployee() async {
    final user = FirebaseAuth.instance.currentUser;

    EmployeeUser? userdata;
    final QuerySnapshot querySnapshot =
        await db.collectionGroup("employee").get();
    querySnapshot.docs.forEach((doc) {
      if (doc.id == user!.phoneNumber)
        userdata = EmployeeUser.fromMap(doc.data() as Map<String, dynamic>);
    });
    return userdata;
  }

  Future<String> employeeLogin(String phone) async {
    if (phone.startsWith("0")) {
      phone = "+6" + phone;
    } else if (phone.startsWith("6")) {
      phone = "+" + phone;
    }
    bool isExist = false;
    bool isActive = false;

    final QuerySnapshot querySnapshot =
        await db.collectionGroup("employee").get();
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      if (phone == docSnapshot.id) {
        isExist = true;
        isActive = data["isActive"];
      }
    }
    if (isExist && isActive) {
      await phoneAuthentication(phone);
      return "";
    } else {
      return "invalid user, user doesn't exist or de-activated";
    }
  }
}
