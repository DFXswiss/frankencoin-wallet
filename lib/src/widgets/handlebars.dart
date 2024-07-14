import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';

class Handlebars {
  static Widget horizontal(
      BuildContext context, {
        EdgeInsetsGeometry margin = const EdgeInsets.only(top: 10),
        double? width,
      }) {
    width ??= MediaQuery.of(context).size.width * 0.25;
    return Container(
      margin: margin,
      height: 5,
      width: width,
      decoration: BoxDecoration(
        color: FrankencoinColors.frDark,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
