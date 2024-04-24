import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRAddressWidget extends StatelessWidget {
  const QRAddressWidget({super.key, required this.address, required this.subtitle});

  final String address;
  final String subtitle;

  @override
  Widget build(BuildContext context) {


    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QrImageView(
          data: address,
          // errorCorrectionLevel: errorCorrectionLevel,
          size: 200,
          eyeStyle: const QrEyeStyle(color: Colors.white),
          dataModuleStyle: const QrDataModuleStyle(
            color: Colors.white,
          ),
          // backgroundColor: backgroundColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  // shortenedAddress,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Lato',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    iconSize: 16,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: address));
  }
}
