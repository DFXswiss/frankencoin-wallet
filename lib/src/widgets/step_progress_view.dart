import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';

class StepProgressView extends StatelessWidget {
  final double width;

  final int steps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double lineHeight = 3;
  final bool isLoading;

  const StepProgressView({
    super.key,
    required this.currentStep,
    required this.steps,
    this.isLoading = true,
    this.width = double.infinity,
    this.activeColor = FrankencoinColors.frRed,
    this.inactiveColor = Colors.grey,
  }) : assert(width > 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(children: _iconViews()),
    );
  }

  List<Widget> _iconViews() {
    final list = <Widget>[];
    for (var i = 0; i < steps; i++) {
      final lineColor = currentStep - 1 > i ? activeColor : inactiveColor;
      final iconColor =
          (i == 0 || currentStep > i) ? activeColor : inactiveColor;

      list.add(Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: i == currentStep - 1 && isLoading
            ? const CupertinoActivityIndicator(color: FrankencoinColors.frRed)
            : Icon(
                Icons.circle,
                color: iconColor,
                size: 16,
              ),
      ));

      //line between icons
      if (i != steps - 1) {
        list.add(
            Expanded(child: Divider(height: lineHeight, color: lineColor)));
      }
    }

    return list;
  }
}
