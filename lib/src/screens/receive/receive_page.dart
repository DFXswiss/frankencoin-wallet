import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/dfx_service.dart';
import 'package:frankencoin_wallet/src/di.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/receive/widgets/qr_address_widget.dart';
import 'package:frankencoin_wallet/src/screens/restore/widgets/option_card.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';
import 'package:frankencoin_wallet/src/wallet/payment_uri.dart';

class ReceivePage extends BasePage {
  ReceivePage(this._appStore, {super.key});

  final AppStore _appStore;

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: Observer(
        builder: (_) {
          final address =
              _appStore.wallet!.currentAccount.primaryAddress.address.hexEip55;
          final shortenedAddress =
              "${address.substring(0, 7)}...${address.substring(address.length - 10)}";

          return Column(
            children: [
              const SizedBox(width: double.infinity),
              QRAddressWidget(
                address: EthereumURI(address: address, amount: '').toString(),
                subtitle: shortenedAddress,
              ),
              OptionCard(
                title: S.of(context).deposit_with_bank_transfer,
                description:
                    S.of(context).deposit_with_bank_transfer_description,
                leadingIcon: Icons.money,
                action: () => getIt
                    .get<DFXService>()
                    .launchProvider(context, true, "bank"),
              ),
              OptionCard(
                title: S.of(context).deposit_with_card,
                description: S.of(context).deposit_with_card_description,
                leadingIcon: Icons.credit_card,
                action: () => getIt
                    .get<DFXService>()
                    .launchProvider(context, true, "card"),
              ),
              if (_appStore.settingsStore.enableExperimentalFeatures)
                OptionCard(
                  title: S.of(context).frankencoin_pay,
                  description: S.of(context).frankencoin_pay_description,
                  leadingIcon: Icons.currency_franc,
                  action: () => Navigator.of(context)
                      .pushNamed(Routes.receiveFrankencoinPay),
                ),
            ],
          );
        },
      ),
    );
  }
}
