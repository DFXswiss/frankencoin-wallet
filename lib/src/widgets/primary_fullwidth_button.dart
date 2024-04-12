import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';

class FullwidthButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color labelColor;
  final Color? backgroundColor;

  const FullwidthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.labelColor = Colors.white,
    this.backgroundColor = FrankencoinColors.frRed,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: labelColor),
            ),
          ),
        ),
      );
}
