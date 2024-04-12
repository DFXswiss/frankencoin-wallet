import 'dart:async';
import 'package:flutter/material.dart';

abstract class BottomSheetService {
  abstract final ValueNotifier<BottomSheetQueueItemModel?> currentSheet;

  Future<dynamic> queueBottomSheet({
    required Widget widget,
    bool isModalDismissible = false,
  });

  void resetCurrentSheet();
}

class BottomSheetServiceImpl implements BottomSheetService {
  @override
  final ValueNotifier<BottomSheetQueueItemModel?> currentSheet =
      ValueNotifier(null);

  @override
  Future<dynamic> queueBottomSheet({
    required Widget widget,
    bool isModalDismissible = false,
  }) async {
    // Create the bottom sheet queue item
    final completer = Completer<dynamic>();
    final queueItem = BottomSheetQueueItemModel(
      widget: widget,
      completer: completer,
      isModalDismissible: isModalDismissible,
    );

    currentSheet.value = queueItem;

    return await completer.future;
  }

  @override
  void resetCurrentSheet() {
    currentSheet.value = null;
  }
}

class BottomSheetQueueItemModel {
  final Widget widget;
  final bool isModalDismissible;
  final Completer<dynamic> completer;

  BottomSheetQueueItemModel({
    required this.widget,
    required this.completer,
    this.isModalDismissible = false,
  });

  @override
  String toString() =>
      'BottomSheetQueueItemModel(widget: $widget, completer: $completer)';
}
