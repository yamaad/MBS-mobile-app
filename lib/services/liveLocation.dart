
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:mbs_fyp/models/orderInfo.dart';

class LiveLocationServices {

  Future updateLocation(LocationData? location, String phone) async {
    if (location != null) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('orders')
          .where("assignedTo.phone", isEqualTo: phone)
          .where("status", isEqualTo: "ongoing")
          .get();

      for (final doc in data.docs) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(doc.id)
            .update({
          "assignedTo.location": {
            "latitude": location.latitude,
            "longitude": location.longitude
          }
        });
      }
    }
  }

Stream<OrderInfo> streamOrder(String orderUid) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(orderUid)
        .snapshots()
        .map((DocumentSnapshot<Object?> snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return OrderInfo.fromMap(data);
    });
  }
}
