import 'package:flutter/material.dart';
import 'package:bip39/src/wordlists/english.dart' as wordlist;

class SeedEditingController extends TextEditingController {
  final nonMatchStyle = const TextStyle(color: Colors.red);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      RegExp(" "),
      onMatch: (Match match) {
        _addTextSpan(textSpanChildren, " ", style);

        return '';
      },
      onNonMatch: (String text) {
        if (wordlist.WORDLIST.contains(text)) {
          _addTextSpan(textSpanChildren, text, style);
        } else {
          _addTextSpan(textSpanChildren, text, style?.merge(nonMatchStyle));
        }

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
    TextStyle? style,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: style,
      ),
    );
  }
}
