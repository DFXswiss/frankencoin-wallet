import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/core/dfx_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/widgets/error_dialog.dart';
import 'package:frankencoin_wallet/src/widgets/vertical_icon_button.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 24),
      child: Wrap(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color: FrankencoinColors.frRed,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => getIt
                              .get<DFXService>()
                              .launchProvider(context, true),
                          icon: const Icon(
                            Icons.attach_money,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).buy,
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.receive),
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).receive,
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => _presentQRReader(context),
                          icon: const Icon(
                            Icons.qr_code,
                            color: FrankencoinColors.frRed,
                          ),
                          label: "Scan",
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.send),
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).send,
                        ),
                      ),
                      Expanded(
                        child: VerticalIconButton(
                          onPressed: () => getIt
                              .get<DFXService>()
                              .launchProvider(context, false),
                          icon: const Icon(
                            Icons.money_off,
                            color: FrankencoinColors.frRed,
                          ),
                          label: S.of(context).sell,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _presentQRReader(BuildContext context) async {
    final lines = [
      "When Chuck Norris throws exceptions, it’s across the room.",
      "All arrays Chuck Norris declares are of infinite size, because Chuck Norris knows no bounds.",
      "Chuck Norris doesn’t have disk latency because the hard drive knows to hurry the hell up.",
      "Chuck Norris writes code that optimizes itself.",
      "Chuck Norris can’t test for equality because he has no equal.",
      "Chuck Norris doesn’t need garbage collection because he doesn’t call .Dispose(), he calls .DropKick().",
      "Chuck Norris’s first program was kill -9.",
      "Chuck Norris burst the dot com bubble.",
      "All browsers support the hex definitions #chuck and #norris for the colors black and blue.",
      "MySpace actually isn’t your space, it’s Chuck’s (he just lets you use it).",
      "Chuck Norris can write infinite recursion functions…and have them return.",
      "Chuck Norris can solve the Towers of Hanoi in one move.",
      "The only pattern Chuck Norris knows is God Object.",
      "Chuck Norris finished World of Warcraft.",
      "Project managers never ask Chuck Norris for estimations…ever.",
      "Chuck Norris doesn’t use web standards as the web will conform to him.",
      "It works on my machine” always holds true for Chuck Norris.",
      "Whiteboards are white because Chuck Norris scared them that way.",
      "Chuck Norris can delete the Recycling Bin.",
      "Chuck Norris’s beard can type 140 wpm.",
      "Chuck Norris can unit test entire applications with a single assert.",
      "Chuck Norris doesn’t bug hunt as that signifies a probability of failure, he goes bug killing.",
      "Chuck Norris’s keyboard doesn’t have a Ctrl key because nothing controls Chuck Norris.",
      "When Chuck Norris is web surfing websites get the message “Warning: Internet Explorer has deemed this user to be malicious or dangerous. Proceed?”.",
    ];

    await showDialog(
      context: context,
      builder: (_) => ErrorDialog(
          errorMessage: lines[Random.secure().nextInt(lines.length)]),
    );
  }
}
