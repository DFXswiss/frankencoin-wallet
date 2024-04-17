import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class SessionProposalModal extends StatelessWidget {
  final String? icon;
  final PairingMetadata metadata;
  final List<String>? chains;
  final List<String> methods;
  final List<String> events;

  const SessionProposalModal({
    super.key,
    this.icon,
    this.chains,
    required this.metadata,
    required this.methods,
    required this.events,
  });

  Widget separatorText(String text) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lato',
            color: Colors.white,
          ),
        ),
      );

  Widget propertyChips(List<String> properties) => Row(
        children: properties
            .map((e) => Padding(
                  padding: const EdgeInsets.all(5),
                  child: Chip(
                    label: Text(
                      e,
                      style: const TextStyle(fontFamily: 'Lato'),
                    ),
                  ),
                ))
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: Text(
            S.current.connection_request,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          ),
        ),
        Row(
          children: [
            if (icon != null) Image.network(icon!, width: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      metadata.url,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (chains != null) ...[
          separatorText(S.of(context).chains),
          propertyChips(chains!),
        ],
        separatorText(S.current.methods),
        propertyChips(methods),

        separatorText(S.current.events),
        propertyChips(events),
      ],
    );
  }
}
