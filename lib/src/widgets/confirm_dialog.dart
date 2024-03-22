import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  Widget body(BuildContext context) => Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
            ),
          ),
        ],
      );

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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: body(context),
          ),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  padding: EdgeInsets.zero,
                  child: Text(S.of(context).cancel),
                ),
              ),
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  color: const Color.fromRGBO(251, 113, 133, 1),
                  padding: EdgeInsets.zero,
                  child: Text(S.of(context).confirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
