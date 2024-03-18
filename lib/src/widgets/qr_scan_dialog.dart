import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

typedef FuncValidateQR = bool Function(String? code, List<int>? rawBytes);
typedef FuncOnQRData = void Function(String? code, List<int>? rawBytes);

class QRScanDialog extends StatefulWidget {
  final FuncValidateQR? validateQR;
  final FuncOnQRData? onData;

  const QRScanDialog({super.key, this.validateQR, this.onData});

  @override
  State<StatefulWidget> createState() => _QRScanDialogState();
}

class _QRScanDialogState extends State<QRScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Expanded(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 10,
                ),
              ),
            ),
          ],
        ),
        SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (widget.validateQR?.call(scanData.code, scanData.rawBytes) == true) {
        widget.onData?.call(scanData.code, scanData.rawBytes);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
