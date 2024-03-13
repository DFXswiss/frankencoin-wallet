import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/widgets/info_dialog.dart';

class SuccessfulTxDialog extends InfoDialog {
  const SuccessfulTxDialog({
    required this.txId,
    super.key,
    super.onConfirm,
  });

  final String txId;

  @override
  String get title => S.current.successful_transaction;

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        Text(
          "${S.of(context).transaction_id} :",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lato',
          ),
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                txId,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            IconButton(
              onPressed: () => _copyToClipboard(txId),
              icon: const Icon(Icons.copy),
            )
          ],
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(String txId) =>
      Clipboard.setData(ClipboardData(text: txId));
}
