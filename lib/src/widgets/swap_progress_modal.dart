import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';
import 'package:frankencoin_wallet/src/widgets/step_progress_view.dart';

class SwapProgressModal extends StatefulWidget {
  final bool isApproved;
  final Future<String> Function() approveSwap;
  final Future<String> Function() confirmSwap;
  final String investAmount;
  final String estimatedProceeds;
  final Blockchain sourceChain;
  final Blockchain targetChain;

  const SwapProgressModal({
    super.key,
    required this.approveSwap,
    required this.confirmSwap,
    required this.investAmount,
    required this.estimatedProceeds,
    this.sourceChain = Blockchain.ethereum,
    this.targetChain = Blockchain.ethereum,
    this.isApproved = false,
  });

  @override
  State<StatefulWidget> createState() => _SwapProgressModalState();
}

class _SwapProgressModalState extends State<SwapProgressModal> {
  _SwapProgressModalState();

  @override
  void initState() {
    if (widget.isApproved) _status = _SwapProgress.approved;
    super.initState();
  }

  _SwapProgress _status = _SwapProgress.created;

  Future<void> _approve() async {
    setState(() => _status = _SwapProgress.approving);
    final txId = await widget.approveSwap.call();
    log("Approve tx: $txId");
    setState(() => _status = _SwapProgress.approved);
  }

  Future<void> _complete() async {
    setState(() => _status = _SwapProgress.executing);
    final txId = await widget.confirmSwap.call();
    Navigator.of(context).pop(txId);
    // await Future.delayed(Duration(seconds: 2));
    // Navigator.of(context).pop("0x0");
  }

  Future<void> _next() async {
    switch (_status) {
      case _SwapProgress.created:
        return _approve();
      case _SwapProgress.approved:
        return _complete();
      case _SwapProgress.done:
        return Navigator.of(context).pop(true);
      default:
        return;
    }
  }

  String get _buttonLabel {
    switch (_status) {
      case _SwapProgress.created:
        return S.of(context).approve;
      case _SwapProgress.approved:
        return S.of(context).confirm;
      default:
        return "";
    }
  }

  List<Widget> _body() {
    switch (_status) {
      case _SwapProgress.created:
      case _SwapProgress.approving:
        return [
          Text(
            S.of(context).approve_amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              S.of(context).approve_amount_swap_description,
              style: const TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
        ];
      case _SwapProgress.approved:
        return [
          SizedBox(
            width: double.infinity,
            child: Text(
              S.of(context).confirm_swap_description(
                  "${widget.investAmount} (${widget.sourceChain.name}) -> ${widget.estimatedProceeds} (${widget.targetChain.name})"),
              style: const TextStyle(
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).execute_swap,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: StepProgressView(
                steps: 3,
                currentStep: _status.step,
                isLoading: _status.isLoading,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(mainAxisSize: MainAxisSize.min, children: _body()),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FullwidthButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: S.of(context).cancel,
                    backgroundColor: null,
                    labelColor: FrankencoinColors.frRed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FullwidthButton(
                    onPressed: _status.isActionable ? _next : null,
                    label: _buttonLabel,
                    isLoading: !_status.isActionable,
                    backgroundColor: FrankencoinColors.frRed,
                    labelColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _SwapProgress {
  created,
  approving,
  approved,
  executing,
  done;

  bool get isActionable =>
      [_SwapProgress.created, _SwapProgress.approved].contains(this);

  bool get isLoading =>
      [_SwapProgress.approving, _SwapProgress.executing].contains(this);

  int get step {
    switch (this) {
      case created:
        return 1;
      case approving:
      case approved:
        return 2;
      case executing:
      case done:
        return 3;
    }
  }
}
