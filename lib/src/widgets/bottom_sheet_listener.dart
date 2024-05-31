import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/core/bottom_sheet_service.dart';
import 'package:frankencoin_wallet/src/widgets/handlebars.dart';

class BottomSheetListener extends StatefulWidget {
  final BottomSheetService bottomSheetService;
  final Widget child;

  const BottomSheetListener({
    required this.child,
    required this.bottomSheetService,
    super.key,
  });

  @override
  BottomSheetListenerState createState() => BottomSheetListenerState();
}

class BottomSheetListenerState extends State<BottomSheetListener> {
  @override
  void initState() {
    super.initState();
    widget.bottomSheetService.currentSheet.addListener(_showBottomSheet);
  }

  @override
  void dispose() {
    widget.bottomSheetService.currentSheet.removeListener(_showBottomSheet);
    super.dispose();
  }

  Future<void> _showBottomSheet() async {
    if (widget.bottomSheetService.currentSheet.value != null) {
      BottomSheetQueueItemModel item =
          widget.bottomSheetService.currentSheet.value!;
      final value = await showModalBottomSheet(
        context: context,
        isDismissible: item.isModalDismissible,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        isScrollControlled: true,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(17, 24, 39, 1),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 16),
                  child: Handlebars.horizontal(context),
                ),
                item.widget
              ],
            ),
          );
        },
      );
      item.completer.complete(value);
      widget.bottomSheetService.resetCurrentSheet();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
