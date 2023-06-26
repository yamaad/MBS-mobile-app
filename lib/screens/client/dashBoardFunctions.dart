import 'package:flutter/material.dart';

class DashboardFunctions {
  static Color orderStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.red.shade300;

      case "ongoing":
        return Colors.yellow.shade900;

      case "declined":
        return Colors.red;

      case "completed":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  static Color shopStatusColor(status) {
    return status ? Colors.green : Colors.red;
  }
}
