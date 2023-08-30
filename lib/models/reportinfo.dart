import 'package:cloud_firestore/cloud_firestore.dart';

class ReportInfo {
  String reporterUid;
  String? orderUid;
  String? reportedUid;
  String title;
  String description;
  bool isResolved;
  DateTime creationTime;

  ReportInfo({
    required this.reporterUid,
    this.orderUid,
    this.reportedUid,
    required this.title,
    required this.description,
    required this.isResolved,
    required this.creationTime,
  });

  factory ReportInfo.fromMap(Map<String, dynamic> map) {
    final Timestamp timestamp = map['creationTime'];

    return ReportInfo(
      reporterUid: map['reporterUid'],
      orderUid: map['orderUid'],
      reportedUid: map['reportedUid'],
      title: map['title'],
      description: map['description'],
      isResolved: map['isResolved'],
      creationTime: timestamp.toDate(),
    );
  }
}
