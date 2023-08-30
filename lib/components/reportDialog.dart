import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/reportinfo.dart';
import 'package:mbs_fyp/services/reportServices.dart';

void showReportDialog(BuildContext context, final reporterUid, String? orderUid,
    String? reportedUid) {
  final ReportServices _reportServices = ReportServices();

  TextEditingController reportTitleController = TextEditingController();
  TextEditingController reportDescriptionController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Report an issue"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Title"),
            TextField(
              controller: reportTitleController,
              maxLines: 2,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            Text("Description"),
            TextField(
              controller: reportDescriptionController,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _reportServices.createReport(ReportInfo(
                  reporterUid: reporterUid,
                  reportedUid: reportedUid,
                  orderUid: orderUid,
                  title: reportTitleController.value.text,
                  description: reportDescriptionController.value.text,
                  isResolved: false,
                  creationTime: DateTime.now()));

              Navigator.pop(context);
            },
            child: Text("Send"),
          ),
        ],
      );
    },
  );
}
