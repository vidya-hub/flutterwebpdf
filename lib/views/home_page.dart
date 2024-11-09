import 'package:flutter/material.dart';
import 'package:flutterwebpdf/provider/pdf_provider.dart';
import 'package:flutterwebpdf/views/pdf_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PdfProvider>(
        builder: (context, pdfProvider, _) {
          return Center(
            child: ElevatedButton(
              onPressed: () async {
                bool isSelected = await pdfProvider.selectPdfFile();
                if (isSelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const PdfPage();
                      },
                    ),
                  );
                }
              },
              child: const Text("Pick Pdf File"),
            ),
          );
        },
      ),
    );
  }
}
