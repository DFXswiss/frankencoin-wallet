import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';

class FrankencoinPayReceivePage extends BasePage {
  FrankencoinPayReceivePage({super.key});

  @override
  String get title => "Frankencoin Pay";

  @override
  Widget body(BuildContext context) => _FrankencoinPayReceivePageBody();
}

class _FrankencoinPayReceivePageBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FrankencoinPayReceivePageBodyState();
}

class _FrankencoinPayReceivePageBodyState
    extends State<_FrankencoinPayReceivePageBody> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
