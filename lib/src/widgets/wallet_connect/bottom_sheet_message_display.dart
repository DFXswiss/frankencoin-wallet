
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';

class BottomSheetMessageDisplayWidget extends StatelessWidget {
  final String message;
  final bool isError;

  const BottomSheetMessageDisplayWidget({super.key, required this.message, this.isError = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isError ? S.current.error : S.current.successful_transaction, // ToDo: replace with successful
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
