import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/widgets/info_dialog.dart';

class ErrorDialog extends InfoDialog {
  const ErrorDialog({
    required this.errorMessage,
    super.key,
    super.onConfirm,
  });

  final String errorMessage;

  @override
  String get title => S.current.error;

  @override
  Widget body(BuildContext context) =>
      Column(
        children: [
          Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
            ),
          ),
        ],
      );
}
