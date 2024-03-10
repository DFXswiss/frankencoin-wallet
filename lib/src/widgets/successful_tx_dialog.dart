import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class SuccessfulTxDialog extends StatelessWidget {
  final String txId;

  final Function? onConfirm;

  const SuccessfulTxDialog({
    super.key,
    required this.onConfirm,
    required this.txId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              S.of(context).successful_transaction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Column(
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
            ),
          ),
          CupertinoButton(
            child: Text(S.of(context).confirm),
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String txId) async {
    await Clipboard.setData(ClipboardData(text: txId));
  }
}
