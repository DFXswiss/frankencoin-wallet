import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';

class Web3RequestModal extends StatelessWidget {
  const Web3RequestModal({required this.child, this.onAccept, this.onReject, super.key});

  final Widget child;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FullwidthButton(
                  onPressed: onReject ?? () => Navigator.of(context).pop(false),
                  label: S.of(context).cancel,
                  backgroundColor: null,
                  labelColor: FrankencoinColors.frRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FullwidthButton(
                  onPressed: onAccept ?? () => Navigator.of(context).pop(true),
                  label: S.of(context).confirm,
                  backgroundColor: FrankencoinColors.frRed,
                  labelColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),),
    );
  }
}
