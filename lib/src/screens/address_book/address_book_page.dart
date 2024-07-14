import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:frankencoin_wallet/src/screens/address_book/widgets/address_book_entry_card.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/routes.dart';
import 'package:frankencoin_wallet/src/view_model/address_book_view_model.dart';

class AddressBookPage extends BasePage {
  final AddressBookViewModel addressBookVM;
  final bool isSelector;

  AddressBookPage(this.addressBookVM, {super.key, this.isSelector = false}) {
    addressBookVM.loadEntries();
  }

  @override
  String get title => S.current.contacts;

  @override
  Widget? trailing(BuildContext context) => MergeSemantics(
        child: SizedBox(
          height: 37,
          width: 37,
          child: ButtonTheme(
            minWidth: double.minPositive,
            child: Semantics(
              label: S.of(context).add_contact,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.addressBookAdd),
                child: Icon(
                  Icons.add,
                  color: pageIconColor(context),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget body(BuildContext context) => SingleChildScrollView(
        child: Observer(
          builder: (_) => Column(
            children: addressBookVM.entries
                .map((e) => AddressBookEntryCard(
                      onTap: isSelector
                          ? () => Navigator.of(context).pop(e)
                          : null,
                      onDelete: isSelector
                          ? null
                          : () => addressBookVM.deleteEntry(e),
                      title: e.name,
                      address: e.address,
                      backgroundColor: FrankencoinColors.frDark,
                    ))
                .toList(),
          ),
        ),
      );
}
