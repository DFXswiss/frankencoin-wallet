import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRAddressWidget extends StatelessWidget {
  const QRAddressWidget({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final shortenedAddress =
        "${address.substring(0, 7)}...${address.substring(address.length - 5)}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QrImageView(
          data: address,
          // errorCorrectionLevel: errorCorrectionLevel,
          size: 150,
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
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shortenedAddress,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}
