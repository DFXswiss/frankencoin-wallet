import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entities/blockchain.dart';
import 'package:frankencoin_wallet/src/entities/crypto_currency.dart';

class BlockchainPicker extends StatelessWidget {
  final List<Blockchain> availableBlockchains;
  final Blockchain selectedBlockchain;
  final Color? textColor;

  const BlockchainPicker({
    super.key,
    required this.availableBlockchains,
    required this.selectedBlockchain,
    this.textColor,
  });

  String getCurrencyImagePath(CryptoCurrency cryptoCurrency) =>
      getCryptoAssetImagePath(cryptoCurrency);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              S.of(context).select_chain,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                color: textColor,
              ),
            ),
          ),
          ...availableBlockchains.map((blockchain) {
            return Padding(
              padding: const EdgeInsets.all(2.5),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(blockchain),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(5, 8, 23, 1),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        getChainAssetImagePath(blockchain.chainId),
                        width: 40,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                blockchain.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (blockchain == selectedBlockchain)
                        Icon(
                          Icons.check_circle,
                          color: textColor,
                        )
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
