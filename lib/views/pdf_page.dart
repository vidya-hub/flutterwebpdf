import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutterwebpdf/provider/pdf_provider.dart';
import 'package:provider/provider.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PdfProvider>(builder: (context, pdfProvider, _) {
        return Column(
          children: [
            SizedBox(
              height: 600,
              child: InAppWebView(
                initialFile: "assets/pdfjs.html",
                onLoadStop: (controller, url) async {
                  await pdfProvider.onWebViewLoaded(controller);
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print("Console Message $consoleMessage");
                },
              ),
            ),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: "Previous page",
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () async {
                      pdfProvider.changePage(toNextPage: false);
                    },
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Enter PageNo:"),
                      ),
                      SizedBox(
                        width: 50,
                        height: 60,
                        child: Center(
                          child: TextField(
                            controller: pdfProvider.pdfPageController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              final pageNo = int.tryParse(value);
                              pdfProvider.jumpToPage(pageNo: pageNo ?? 1);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "/${pdfProvider.pdfPagesCount}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    ],
                  ),
                  IconButton(
                    tooltip: "Next page",
                    icon: Icon(
                      Icons.arrow_forward,
                    ),
                    onPressed: () async {
                      pdfProvider.changePage(toNextPage: true);
                      // await provider.nextPage();
                    },
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
