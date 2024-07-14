import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/widgets/primary_fullwidth_button.dart';

class NumberInputWidget extends StatefulWidget {
  const NumberInputWidget({
    super.key,
    required this.maxLength,
    required this.onChange,
    required this.onComplete,
    this.onMaxAmount,
    this.buttonLabel,
    this.inputSuffix,
  });

  final void Function(String amount)? onMaxAmount;
  final void Function(String amount) onChange;
  final void Function(String amount) onComplete;
  final int maxLength;
  final String? buttonLabel;
  final String? inputSuffix;

  @override
  State<StatefulWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState<T extends NumberInputWidget> extends State<T> {
  _NumberInputWidgetState()
      : _aspectRatio = 0,
        inputAmount = '';
  final _gridViewKey = GlobalKey();
  String inputAmount;
  double _aspectRatio;

  int get currentPinLength => inputAmount.length;

  @override
  void initState() {
    super.initState();
    _aspectRatio = 0;
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void calculateAspectRatio() {
    final renderBox =
        _gridViewKey.currentContext!.findRenderObject() as RenderBox;
    final cellWidth = renderBox.size.width / 3;
    final cellHeight = renderBox.size.height / 4;

    if (cellWidth > 0 && cellHeight > 0) _aspectRatio = cellWidth / cellHeight;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) => KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (keyEvent) {
          print(keyEvent.runtimeType);
          if (keyEvent is KeyDownEvent) {
            if (keyEvent.logicalKey.keyLabel == "Backspace") {
              _pop();
              return;
            }
            if ([",", "."].contains(keyEvent.character)) _push(".");

            int? number = int.tryParse(keyEvent.character ?? '');
            if (number != null) _push(number.toString());
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
          color: FrankencoinColors.frDark,
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              SizedBox(
                width: 250,
                child: AutoSizeText(
                  "$inputAmount${widget.inputSuffix != null ? " ${widget.inputSuffix}" : ""}",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Flexible(
                flex: 15,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Container(
                      key: _gridViewKey,
                      child: _aspectRatio > 0
                          ? ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                childAspectRatio: _aspectRatio,
                                physics: const NeverScrollableScrollPhysics(),
                                children: List.generate(12, (index) {
                                  const double marginRight = 15;
                                  const double marginLeft = 15;

                                  if (index == 9) {
                                    return _circleTextButton(
                                        ".", marginLeft, marginRight);
                                  } else if (index == 10) {
                                    index = 0;
                                  } else if (index == 11) {
                                    return MergeSemantics(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: marginLeft,
                                            right: marginRight),
                                        child: Semantics(
                                          label: "Delete", // ToDo
                                          button: true,
                                          onTap: () => _pop(),
                                          child: TextButton(
                                            onPressed: () => _pop(),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  FrankencoinColors.frLightDark,
                                              shape: const CircleBorder(),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.delete_left_fill,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    index++;
                                  }

                                  return _circleTextButton(
                                      "$index", marginLeft, marginRight);
                                }),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (widget.buttonLabel != null)
                FullwidthButton(
                  label: widget.buttonLabel!,
                  onPressed: () => widget.onComplete(inputAmount),
                )
            ],
          ),
        ),
      );

  void _push(String input) {
    setState(() {
      if (currentPinLength >= widget.maxLength) return;

      if (input == "0" && inputAmount.isEmpty) input += ".";
      if (input == ".") inputAmount = inputAmount.replaceAll(".", "");
      inputAmount += input;

      widget.onChange(inputAmount);

      if (inputAmount.length == widget.maxLength) {
        widget.onMaxAmount?.call(inputAmount);
      }
    });
  }

  void _pop() {
    if (currentPinLength == 0) return;

    setState(
        () => inputAmount = inputAmount.substring(0, inputAmount.length - 1));
  }

  void _afterLayout(dynamic _) {
    calculateAspectRatio();
  }

  Widget _circleTextButton(
          String label, double marginLeft, double marginRight) =>
      Container(
        margin: EdgeInsets.only(left: marginLeft, right: marginRight),
        child: TextButton(
          onPressed: () => _push(label),
          style: TextButton.styleFrom(
            backgroundColor: FrankencoinColors.frLightDark,
            shape: const CircleBorder(),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
}
