import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/core/asset_logo.dart';
import 'package:frankencoin_wallet/src/entities/custom_erc20_token.dart';

class CustomTokenIcon extends StatelessWidget {
  final CustomErc20Token erc20token;

  const CustomTokenIcon({super.key, required this.erc20token});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 45,
        height: 45,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            erc20token.icon!,
            Positioned(
              bottom: -5,
              right: -5,
              width: 20,
              child: Image.asset(
                getChainAssetImagePath(erc20token.chainId),
              ),
            ),
          ],
        ),
      );
}
