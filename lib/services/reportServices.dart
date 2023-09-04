
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbs_fyp/models/reportinfo.dart';

class ReportServices {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<ReportInfo> reports = [];

  Future createReport(ReportInfo report) async {
    final reportUid = await db.collection("report").doc();
    await db.collection("report").doc(reportUid.id).set({
      "uid": reportUid.id,
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
          .collection("report")
          .where('isResolved', isEqualTo: false)
          .orderBy('creationTime', descending: false)
          .where('creationTime', isGreaterThan: reports.last.creationTime)
          .limit(5)
          .get();
    } else {
      data = await db
          .collection("report")
          .where('isResolved', isEqualTo: false)
          .orderBy('creationTime', descending: false)
          .limit(10)
          .get();
    }
    for (final doc in data.docs) {
      reports.add(ReportInfo.fromMap(doc.data() as Map<String, dynamic>));
    }
    return reports;
  }

  Future resolveReport(String reportUid) async {
    await db.collection("report").doc(reportUid).update({"isResolved": true});
    final resolvedIndex =
        reports.indexWhere((element) => element.uid == reportUid);

    reports.removeAt(resolvedIndex);
  }
}
