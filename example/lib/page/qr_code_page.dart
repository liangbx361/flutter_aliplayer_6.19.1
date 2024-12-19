import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewPageStatus();
}


class _QRViewPageStatus extends State<QRViewPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String? qrText;


  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    if(null!= controller){
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller){
    this.controller=controller;
    controller.scannedDataStream.listen((scanData){
      setState(() {
        qrText=scanData.code;
      });
      // Close the QR view and pass the scanned code to the previous screen
      Navigator.of(context).pop(scanData.code);
      dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.lightBlue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }
// QRVIewC
}