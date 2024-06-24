import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/screens/send/widgets/blockchain_picker.dart';

class BlockchainSelector extends StatelessWidget {
  const BlockchainSelector({
    super.key,
    required this.bottomSheetService,
    required this.blockchain,
    this.availableBlockchains = Blockchain.values,
    this.onSelect,
  });

  final BottomSheetService bottomSheetService;
  final Blockchain blockchain;
  final List<Blockchain> availableBlockchains;
  final Function(Blockchain)? onSelect;

  Future<void> _onTapProvider() async {
    final selectedChain = await bottomSheetService.queueBottomSheet(
      isModalDismissible: true,
      widget: BlockchainPicker(
        selectedBlockchain: blockchain,
        availableBlockchains: availableBlockchains,
        textColor: Colors.white,
      ),
    ) as Blockchain?;

    log("Selected Chain: $selectedChain");
    if (selectedChain != null) onSelect?.call(selectedChain);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${S.of(context).blockchain}:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: _onTapProvider,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Image.asset(
                      getChainAssetImagePath(blockchain.chainId),
                      width: 22,
                    ),
                  ),
                  Text(
                    blockchain.name,
                    style: const TextStyle(
                      fontSize: 15,
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
    );
  }
}
