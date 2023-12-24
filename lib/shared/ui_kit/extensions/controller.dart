import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

OverlayEntry? overlayEntry;
const Duration defaultOverlayDelayDuration = Duration(milliseconds: 100);

class IOSOverlayEntry extends StatelessWidget {
  const IOSOverlayEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CupertinoActivityIndicator());
  }
}

class IOSActionData {
  const IOSActionData({required this.label, this.isDefault = false, this.isDestructive = false});

  final String label;
  final bool isDefault;
  final bool isDestructive;
}

extension UIControllerExtension on GetxController {
  showIOSLoadingOverlay(BuildContext context) {
    overlayEntry = OverlayEntry(builder: (_) => const IOSOverlayEntry());
    Overlay.of(context).insert(overlayEntry!);
  }

  hideIOSLoadingOverlay({Duration delay = defaultOverlayDelayDuration}) async {
    if (overlayEntry == null) return;
    await Future.delayed(delay);
    overlayEntry?.remove();
    overlayEntry == null;
  }

  showIOSConfirmationDialog(
    BuildContext context, {
    required String title,
    required String description,
    required FutureOr<void> Function(bool result, BuildContext context) onResultHandler,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
  }) async {
    await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
            isDefaultAction: true,
            child: Text(cancelText),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            isDestructiveAction: true,
            child: Text(confirmText),
          ),
        ],
      ),
    ).then((result) => onResultHandler.call(result ?? false, context));
  }

  showIOSModalPopUp(
    BuildContext context, {
    required List<IOSActionData> actions,
    required FutureOr<void> Function(int? index, BuildContext context) onResultHandler,
    String cancelText = 'Cancel',
    Widget? title,
    Widget? message,
  }) async {
    await showCupertinoModalPopup<int?>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: CupertinoActionSheet(
              title: title,
              message: message,
              actions: actions
                  .mapIndexed(
                    (i, e) => CupertinoActionSheetAction(
                      isDefaultAction: e.isDefault,
                      isDestructiveAction: e.isDestructive,
                      child: Text(e.label),
                      onPressed: () {
                        Navigator.of(context).pop(i);
                      },
                    ),
                  )
                  .toList(),
              cancelButton: CupertinoButton(child: Text(cancelText), onPressed: () => Navigator.pop(context)),
            ),
          );
        }).then((value) => onResultHandler.call(value, context));
  }
}
