import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopInfo.dart';
import '../models/user.dart';
import 'locationServeices.dart';

class AuthSevrices {
  FirebaseFirestore db = FirebaseFirestore.instance;

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
          "services": [] as String,
          "pricing": 5.0,
          "pricingCount": 0,
          "service": 5.0,
          "serviceCount": 0,
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

  Future<String> getUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = db.collection("user").doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        return doc.get('userType');
      }
      return "User not found";
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
}
