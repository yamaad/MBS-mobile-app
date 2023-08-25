import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/models/shopInfo.dart';

class AdminServices {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<ShopInfo>> getNewShops() async {
    final userType = 'client';
    List<ShopInfo> userList = [];
    final docRef = db.collection('user');

    final snapshot = await docRef
        .where('userType', isEqualTo: userType)
        .where('isActive', isEqualTo: false)
        .get();

    snapshot.docs.forEach((doc) {
      final shopInfo = ShopInfo.fromMap(doc.data());
      userList.add(shopInfo);
    });
    return userList;
  }

  Future<List<ShopInfo>> getSuspendedShops() async {
    List<ShopInfo> userList = [];
    final docRef = db.collection('user');

    final snapshot =
        await docRef.where('userType', isEqualTo: 'suspend-client').get();

    snapshot.docs.forEach((doc) {
      final shopInfo = ShopInfo.fromMap(doc.data());
      userList.add(shopInfo);
    });
    return userList;
  }

  Future<List<CustomerUser>> getSuspendedCustomer() async {
    List<CustomerUser> userList = [];
    final docRef = db.collection('user');

    final snapshot =
        await docRef.where('userType', isEqualTo: 'suspend-customer').get();

    snapshot.docs.forEach((doc) {
      final customerUser = CustomerUser.fromMap(doc.data());
      userList.add(customerUser);
    });
    return userList;
  }

  Future accountActivation(final userId, bool approval) async {
    if (approval) {
      await db.collection("user").doc(userId).update({"isActive": true});
    } else
      await db
          .collection("user")
          .doc(userId)
          .update({'userType': "suspend-client"});
  }

  Future reActivateAcounts(final userId, userType) async {
    if (userType == "suspend-client") {
      await db
          .collection("user")
          .doc(userId)
          .update({'userType': "client", "isActive": true});
    } else if (userType == "suspend-customer") {
      await db
          .collection("user")
          .doc(userId)
          .update({'userType': "customer", "isActive": true});
    }
  }

  Future deActivateAcounts(final userId, userType) async {
    if (userType == "client") {
      await db.collection("user").doc(userId).update(
          {'userType': "suspend-client", "isActive": false, "status": false});
    } else if (userType == "customer") {
      await db
          .collection("user")
          .doc(userId)
          .update({'userType': "suspend-customer", "isActive": false});
    }
  }
}
