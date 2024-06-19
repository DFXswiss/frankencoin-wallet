import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';

class BottomSheetMessageDisplayWidget extends StatelessWidget {
  final String message;
  final String? title;

  const BottomSheetMessageDisplayWidget(
      {super.key, required this.message, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title ?? S.current.error,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,

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
          const SizedBox(height: 15),
          FullwidthButton(
            onPressed: () => Navigator.of(context).pop(true),
            label: S.of(context).okay,
            backgroundColor: FrankencoinColors.frRed,
            labelColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
