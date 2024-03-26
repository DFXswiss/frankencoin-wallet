import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/screens/base_page.dart';
import 'package:frankencoin_wallet/src/screens/settings/widgets/option_row.dart';
import 'package:frankencoin_wallet/src/stores/app_store.dart';

class ManageNodesPage extends BasePage {
  ManageNodesPage(this.appStore, {super.key});

  final AppStore appStore;

  @override
  String get title => S.current.nodes;

  @override
  Widget body(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Observer(
        builder: (_) => Column(
          children: [
            ...appStore.settingsStore.nodes.map(
              (e) => OptionRow(
                name: e.name,
                leading: Image.asset(
                  "assets/images/crypto/eth.png",
                  width: 40,
                ),
                canEdit: true,
                // onTap: _edit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                height: 5,
                width: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(17, 24, 39, 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                S.of(context).edit_node,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
