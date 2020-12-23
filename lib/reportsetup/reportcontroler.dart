import 'package:absenin/reportsetup/reportmodel.dart';
import 'package:absenin/reportsetup/reportstaffmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportController {
  final void Function(String) callback;
  String URL;
  static const STATUS_SUCCESS = "SUCCESS";

  ReportController(this.callback);

  void submitReport(FeedbackReport feedbackReport, String url) async {
    URL = url;
    try {
      await http.get(URL + feedbackReport.toParams()).then((response) {
        callback(jsonDecode(response.body)['status']);
      });
    } catch (e) {
      print('Error : $e');
    }
  }

  void submitStaffReport(FeedbackReportStaff feedbackReport, String url) async {
    URL = url;
    try {
      await http.get(URL + feedbackReport.toParams()).then((response) {
        callback(jsonDecode(response.body)['status']);
      });
    } catch (e) {
      print('Error : $e');
    }
  }
}
