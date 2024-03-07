import 'package:flutter/cupertino.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class ConfirmationAlert extends StatelessWidget {
  final Function onConfirm;
  final Function onDecline;

  const ConfirmationAlert({
    super.key,
    required this.onConfirm,
    required this.onDecline,
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
            child: const Text(
              "Sicher?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                child: const Text("Abbrechen"),
                onPressed: () {
                  onDecline.call();
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              CupertinoButton(
                child: const Text("Akzeptieren"),
                onPressed: () {
                  onConfirm.call();
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
