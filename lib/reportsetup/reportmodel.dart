class FeedbackReport {
  String nomor,
      name,
      dayin,
      dayintotaltime,
      totalbreaktime,
      overtimeday,
      overtimetotaltime,
      latee,
      latetotaltime,
      dayoff,
      permission,
      notattend;

  FeedbackReport(
      this.nomor,
      this.name,
      this.dayin,
      this.dayintotaltime,
      this.totalbreaktime,
      this.overtimeday,
      this.overtimetotaltime,
      this.latee,
      this.latetotaltime,
      this.dayoff,
      this.permission,
      this.notattend);

  String toParams() =>
      "?nomor=$nomor&nama=$name&masuk=$dayin&totaljamkerja=$dayintotaltime&totaljamistirahat=$totalbreaktime&lembur=$overtimeday&totaljamlembur=$overtimetotaltime&terlambat=$latee&totaljamterlambat=$latetotaltime&totalcuti=$dayoff&totalijin=$permission&totaltdkmasuk=$notattend";
}
