import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewer extends StatefulWidget {
  final String urlFile;

  const PdfViewer({Key key, this.urlFile}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PdfViewerState();
  }
}

class PdfViewerState extends State<PdfViewer> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(widget.urlFile);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission File'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(strokeWidth: 3.0))
              : PDFViewer(
                  document: document,
                  zoomSteps: 1,
                )),
    );
  }
}
