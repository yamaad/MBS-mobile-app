import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbs_fyp/models/reportinfo.dart';

class ReportServices {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<ReportInfo> reports = [];

  Future createReport(ReportInfo report) async {
    await db.collection("report").doc().set({
      "reporterUid": report.reporterUid,
      "orderUid": report.orderUid ?? "",
      "reportedUid": report.reportedUid ?? "",
      "title": report.title,
      "description": report.description,
      "isResolved": report.isResolved,
      'creationTime': report.creationTime,
    });
  }

  Future<List<ReportInfo>> getUnresovledReports() async {
    QuerySnapshot data;
    if (reports.isNotEmpty) {
      data = await db
          .collection("reports")
          .where('isResloved', isEqualTo: false)
          .orderBy('creationTime', descending: true)
          .where('creationTime', isLessThan: reports.last.creationTime)
          .limit(5)
          .get();
    } else {
      data = await db
          .collection("reports")
          .where('isResloved', isEqualTo: false)
          .orderBy('creationTime', descending: true)
          .limit(10)
          .get();
    }
    for (final doc in data.docs) {
      reports.add(ReportInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return reports;
  }
}
