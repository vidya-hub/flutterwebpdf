import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PdfProvider extends ChangeNotifier {
  String selectedFileBase64 = "";
  InAppWebViewController? _webViewController;
  int pdfPagesCount = 0;
  int currentPage = 1;
  TextEditingController pdfPageController = TextEditingController();

  Future<bool> selectPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );
    if (result != null && result.files.isNotEmpty) {
      final selectedFile = File(result.files.single.path!);
      selectedFileBase64 = await convertBase64(selectedFile);
      return true;
    }
    return false;
  }

  Future<String> convertBase64(File file) async {
    List<int> pdfBytes = await file.readAsBytes();
    String base64File = base64Encode(pdfBytes);
    return base64File;
  }

  Future onWebViewLoaded(InAppWebViewController webViewController) async {
    _webViewController = webViewController;
    _webViewController?.evaluateJavascript(
      source: "renderPdf('$selectedFileBase64')",
    );
    addTotalPdfPagesListener();
    addCurrentPageListener();
  }

  void addTotalPdfPagesListener() {
    _webViewController?.addJavaScriptHandler(
      handlerName: "totalPdfPages",
      callback: (List data) {
        if (data.isNotEmpty && data.first is int) {
          pdfPagesCount = data.first;
          notifyListeners();
        }
      },
    );
  }

  void addCurrentPageListener() {
    _webViewController?.addJavaScriptHandler(
      handlerName: "currentPage",
      callback: (List data) {
        if (data.isNotEmpty && data.first is int) {
          currentPage = data.first;
          pdfPageController.text = currentPage.toString();
          notifyListeners();
        }
      },
    );
  }

  void jumpToPage({
    int pageNo = 1,
  }) {
    _webViewController?.evaluateJavascript(
      source: "jumpToPage($pageNo)",
    );
  }

  void changePage({bool toNextPage = false}) {
    _webViewController?.evaluateJavascript(
      source: "changePage($toNextPage)",
    );
  }
}
