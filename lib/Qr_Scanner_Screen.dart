import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/link.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrkey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedCode;
  bool linkVisited = false;

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scannedata) {
      setState(() {
        scannedCode = scannedata.code!;
      });
      // controller.pauseCamera();
    });
  }

  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.resumeCamera();
    } else if (Platform.isIOS) {
      controller!.pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: Text(
          "QR Scanner",
          style: TextStyle(
              color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          height: 600,
          width: 300,
          child: Column(
            children: <Widget>[
              Text(
                'Place the QR inside the frame',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              SizedBox(height: 12),
              Expanded(
                flex: 6,
                child: QRView(key: qrkey, onQRViewCreated: onQRViewCreated),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Scanned Code:',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    if (scannedCode != null)
                      Link(
                          uri: Uri.parse('$scannedCode'),
                          builder: (context, followLink) => TextButton(
                                onPressed: () {
                                  followLink!();
                                  setState(() {
                                    linkVisited = true;
                                  });
                                  SizedBox(
                                    height: 30,
                                  );
                                  // Follow the link
                                },
                                child: linkVisited
                                    ? ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueAccent),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            controller!.resumeCamera();
                                            scannedCode = null;
                                            linkVisited = false;
                                          });
                                        },
                                        child: Text(
                                          'Scan again',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ))
                                    : Text(
                                        '$scannedCode',
                                        style: TextStyle(fontSize: 25),
                                      ),
                              ))
                    else
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Scan',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
