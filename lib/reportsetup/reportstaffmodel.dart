class FeedbackReportStaff {
  final String nomor,
      tanggal,
      shift,
      posisi,
      jammasuk,
      jamistirahat,
      jammasuk2,
      jamkeluar,
      jammasuklembur,
      jamkeluarlembur,
      totaljamkerja,
      totaljamistirahat,
      totaljamlembur,
      totaljamterlambat;

  FeedbackReportStaff(
      this.nomor,
      this.tanggal,
      this.shift,
      this.posisi,
      this.jammasuk,
      this.jamistirahat,
      this.jammasuk2,
      this.jamkeluar,
      this.jammasuklembur,
      this.jamkeluarlembur,
      this.totaljamkerja,
      this.totaljamistirahat,
      this.totaljamlembur,
      this.totaljamterlambat);

  String toParams() =>
      "?nomor=$nomor&tanggal=$tanggal&shift=$shift&posisi=$posisi&jammasuk=$jammasuk&jamistirahat=$jamistirahat&jammasuk2=$jammasuk2&jamkeluar=$jamkeluar&jammasuklembur=$jammasuklembur&jamkeluarlembur=$jamkeluarlembur&totaljamkerja=$totaljamkerja&totaljamistirahat=$totaljamistirahat&totaljamlembur=$totaljamlembur&totaljamterlambat=$totaljamterlambat";
}
