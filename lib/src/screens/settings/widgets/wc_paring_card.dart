import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';

class WCParingCard extends StatelessWidget {
  final PairingInfo paringInfo;
  final String? actionLabel;
  final void Function()? action;

  const WCParingCard({
    super.key,
    required this.paringInfo,
    this.actionLabel,
    this.action,
  });

  String get expiryDay {
    final date = DateTime.fromMillisecondsSinceEpoch(paringInfo.expiry * 1000);

    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$day.$month.${date.year} $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    PairingMetadata? metadata = paringInfo.peerMetadata;

    return InkWell(
      onTap: null,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(5, 8, 23, 1),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                metadata?.icons[0] != null
                    ? Image.network(metadata!.icons[0], width: 40)
                    : Image.asset('assets/images/frankencoin.png', width: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metadata?.name ?? "TODO",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                              color: Colors.white),
                        ),
                        if (metadata?.url != null)
                          Text(
                            metadata!.url,
                            style: const TextStyle(
                                fontFamily: 'Lato', color: Colors.white),
                          ),
                        Text(
                          "${S.of(context).expires_on}: $expiryDay",
                          style: const TextStyle(
                              fontFamily: 'Lato', color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (actionLabel != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: FrankencoinColors.frRed,
                    onPressed: action,
                    child: Text(actionLabel!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
