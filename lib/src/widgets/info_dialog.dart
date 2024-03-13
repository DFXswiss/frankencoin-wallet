import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

abstract class InfoDialog extends StatelessWidget {
  final Function? onConfirm;

  const InfoDialog({
    super.key,
    required this.onConfirm,
  });

  String get title;

  Widget body(BuildContext context);

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
              title,
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
            child: body(context),
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
}
