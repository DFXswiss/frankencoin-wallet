import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/core/swap_routes.dart';
import 'package:frankencoin_wallet/src/widgets/wallet_connect/bottom_sheet_message_display.dart';

class SwapRouteInfos extends StatelessWidget {
  const SwapRouteInfos({
    super.key,
    required this.swapRoute,
    required this.bottomSheetService,
  });

  final BottomSheetService bottomSheetService;
  final SwapRoute swapRoute;

  void _onTapProvider() {
    bottomSheetService.queueBottomSheet(
      isModalDismissible: true,
      widget: BottomSheetMessageDisplayWidget(
          title: "Swap Route Info",
          message: 'This Swap is provided by ${swapRoute.provider.name}'),
    );
  }

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
          InkWell(
            onTap: _onTapProvider,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage(swapRoute.provider.icon),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Text(
                    swapRoute.provider.name,
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
