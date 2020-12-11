class FeedbackReport{

  String name, dayin, dayintotaltime, totalbreaktime, overtimeday, overtimetotaltime, latee, latetotaltime, dayoff, permission, notattend;

  FeedbackReport(this.name, this.dayin, this.dayintotaltime, this.totalbreaktime, this.overtimeday, this.overtimetotaltime, this.latee, this.latetotaltime, this.dayoff, this.permission, this.notattend);

  String toParams() => "?nama=$name&masuk=$dayin&totaljamkerja=$dayintotaltime&totaljamistirahat=$totalbreaktime&lembur=$overtimeday&totaljamlembur=$overtimetotaltime&terlambat=$latee&totaljamterlambat=$latetotaltime&totalcuti=$dayoff&totalijin=$permission&totaltdkmasuk=$notattend";

}