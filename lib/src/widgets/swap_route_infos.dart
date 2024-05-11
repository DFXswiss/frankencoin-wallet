import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/core/swap_service.dart';

class SwapRouteInfos extends StatelessWidget {
  const SwapRouteInfos({
    super.key,
    required this.swapRoute,
  });

  final SwapRoute swapRoute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${S.of(context).swap_provider}:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundImage:
                AssetImage(SwapService.getSwapProviderImage(swapRoute.provider)),
          ),
          Text(
            swapRoute.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
