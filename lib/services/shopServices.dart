import 'package:cloud_firestore/cloud_firestore.dart';

class ShopServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateClientStatus(
    String clientId,
    bool status,
  ) async {
    try {
      await _firestore.collection('user').doc(clientId).update({
        'status': status,
      });
      print('Client status and services updated successfully');
    } catch (e) {
      print('Error updating client status and services: $e');
      // Handle the error as needed
    }
  }

  Future<bool> getStatus(String clientId) async {
    try {
      final docRef = _firestore.collection("user").doc(clientId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          final status = data['status'] as bool;
          return status;
        } else {
          await this.updateClientStatus(clientId, false);
          return false;
        }
      } else {
        await this.updateClientStatus(clientId, false);
        return false;
      }
    } catch (e) {
      print('Error retrieving status: $e');
      return false;
    }
  }

  Future<void> updateClientServices(
    String clientId,
    List<String> services,
  ) async {
    try {
      await _firestore.collection('user').doc(clientId).update({
        'services': services,
      });
      print('Client status and services updated successfully');
    } catch (e) {
      print('Error updating client status and services: $e');
      // Handle the error as needed
    }
  }

  Future<List<String>> getServices(String clientId) async {
    try {
      final docRef = _firestore.collection("user").doc(clientId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          final services = data['services'] as List<String>;
          return services;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error retrieving status: $e');
      return [];
    }
  }
}
