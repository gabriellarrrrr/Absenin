import 'package:absenin/reportsetup/reportmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportController{

  final void Function(String) callback;
  static const String URL = "https://script.google.com/macros/s/AKfycbzfNygSqqJOsweh82O-Ip-3H9y5qapqaofB5q5ImixDqppgaGs8/exec";
  static const STATUS_SUCCESS = "Success";

  ReportController(this.callback);

  void submitReport(FeedbackReport feedbackReport) async {

    try{
      await http.get(URL + feedbackReport.toParams()).then(
          (response){
            callback(jsonDecode(response.body)['status']);
          });
    } catch(e){
      print('Error : $e');
    }

  }

}