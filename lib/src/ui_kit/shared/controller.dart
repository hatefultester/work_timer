import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/device_service.dart';
import 'gap.dart';

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
      barrierDismissible: true,
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
        barrierDismissible: true,
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

  showIOSTimerPicker(
    BuildContext context, {
    required Duration initialTimerDuration,
    required void Function(Duration duration) onDurationChanged,
    void Function(BuildContext context, Duration initialTimerDuration, bool wasConfirmed)? onClosed,
  }) {
    showCupertinoModalPopup<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: initialTimerDuration,
                onTimerDurationChanged: onDurationChanged,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CupertinoButton(
                    child: const Text('Save'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ).then((result) => onClosed?.call(context, initialTimerDuration, result ?? false));
  }

  showIOSAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Ok'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  showIOSCreationBottomSheet<T>(
    BuildContext context, {
    required Widget view,
    required T initialValue,
    required FutureOr<void> Function(BuildContext, T initial, T? saved) onClosed,
  }) async {
    final maxHeight = DeviceService.to.deviceHeight(context) * 0.8;

    showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => DecoratedBox(decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
      ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(

                constraints: BoxConstraints(maxHeight: maxHeight),
                child: SingleChildScrollView(child: view),
              );
            },
          ),
        ),
      ),
    ).then(
      (value) {
        onClosed.call(context, initialValue, value);
      },
    );
  }

  showIOSColorCustomizationBottomSheet(
    BuildContext ancestorContext, {
    required List<IOSColorCustomizationBottomSheetOption> options,
    required FutureOr<void> Function(List<IOSColorCustomizationBottomSheetOption>, BuildContext) onChanged,
    required FutureOr<void> Function(BuildContext, List<IOSColorCustomizationBottomSheetOption>, bool) onClosed,
  }) async {
    showModalBottomSheet<bool?>(
      context: ancestorContext,
      builder: (context) => GetBuilder<ShowIOSColorCustomizationBottomSheetController>(
        init: ShowIOSColorCustomizationBottomSheetController(options, onChanged, context),
        builder: (controller) => Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          ),
          child: Stack(
            children: [
              Builder(
                builder: (context) {
                  final selectedModel = controller.models[controller.selectedIndex];
                  return DefaultTextStyle(
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Obx(() {
                            final r = (selectedModel.r.value).toInt();
                            final g = (selectedModel.g.value).toInt();
                            final b = (selectedModel.b.value).toInt();
                            const opacity = 1.0;
                            final resolvedColor = Color.fromRGBO(r, g, b, opacity);
                            return Container(
                              margin: const EdgeInsets.all(16),
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: resolvedColor,
                                border: Border.all(color: CupertinoColors.label.resolveFrom(context), width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(),
                            );
                          }),
                        ),
                        Obx(() => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('R:'),
                                      Gap.h8,
                                      SizedBox(
                                          width: 255,
                                          child: CupertinoSlider(
                                              value: IOSColorCustomizationRxRGBModel.convert(selectedModel.r.value),
                                              onChanged: selectedModel.onRChanged)),
                                      Gap.h8,
                                      Text('${selectedModel.r.value.toInt()}')
                                    ],
                                  )),
                            )),
                        Obx(() => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('G:'),
                                      Gap.h8,
                                      SizedBox(
                                          width: 255,
                                          child: CupertinoSlider(
                                              value: IOSColorCustomizationRxRGBModel.convert(selectedModel.g.value),
                                              onChanged: selectedModel.onGChanged)),
                                      Gap.h8,
                                      Text('${selectedModel.g.value.toInt()}')
                                    ],
                                  )),
                            )),
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: 45,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('B:'),
                                  Gap.h8,
                                  SizedBox(
                                    width: 255,
                                    child: CupertinoSlider(
                                        value: IOSColorCustomizationRxRGBModel.convert(selectedModel.b.value),
                                        onChanged: selectedModel.onBChanged),
                                  ),
                                  Gap.h8,
                                  Text('${selectedModel.b.value.toInt()}')
                                ],
                              ),
                            ),
                          ),
                        ),
                        Gap.v16,
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: CupertinoSegmentedControl<int>(
                                groupValue: controller.selectedIndex,
                                children: controller.segments,
                                onValueChanged: controller.segmentChanged),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.topRight,
                child: Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CupertinoButton(
                      child: const Text('Save'),
                      onPressed: () => controller.saveToggled(context),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    ).then((value) {
      onClosed.call(ancestorContext, options, value ?? false);
    });
  }
}

class IOSColorCustomizationBottomSheetOption {
  const IOSColorCustomizationBottomSheetOption({required this.label, required this.value});

  final String label;
  final Color value;
}

class IOSColorCustomizationRxRGBModel {
  IOSColorCustomizationRxRGBModel(this.r, this.g, this.b, this.o);

  factory IOSColorCustomizationRxRGBModel.fromColor(Color color) => IOSColorCustomizationRxRGBModel(
      color.red.toDouble().obs, color.green.toDouble().obs, color.blue.toDouble().obs, color.opacity.obs);

  final Rx<double> r;
  final Rx<double> g;
  final Rx<double> b;
  final Rx<double> o;

  static double convert(double value) => value / 255;

  void onBChanged(double value) {
    final converted = value * 255;
    b.value = converted;
  }

  void onGChanged(double value) {
    final converted = value * 255;
    g.value = converted;
  }

  void onRChanged(double value) {
    final converted = value * 255;
    r.value = converted;
  }
}

class ShowIOSColorCustomizationBottomSheetController extends GetxController {
  final List<IOSColorCustomizationBottomSheetOption> options;
  late final List<IOSColorCustomizationRxRGBModel> models;
  late int selectedIndex = 0;

  final FutureOr<void> Function(List<IOSColorCustomizationBottomSheetOption>, BuildContext) onChanged;

  late Worker updateWorker;
  late Worker updateNotifierDebouncer;
  late final Rxn<List<IOSColorCustomizationBottomSheetOption>> updateOptions;

  final BuildContext dialogContext;

  @override
  onClose() {
    updateWorker.dispose();
    updateNotifierDebouncer.dispose();
    updateOptions.dispose();
    super.onClose();
  }

  ShowIOSColorCustomizationBottomSheetController(this.options, this.onChanged, this.dialogContext) {
    models = options.map((e) => IOSColorCustomizationRxRGBModel.fromColor(e.value)).toList();
    updateOptions = Rxn();
    updateWorker = everAll(models.expand((e) => [e.r, e.o, e.b, e.g]).toList(), (callback) {
      updateOptions.value = models
          .mapIndexed(
            (index, element) => IOSColorCustomizationBottomSheetOption(
              label: options[index].label,
              value: Color.fromRGBO(
                  element.r.value.toInt(), element.g.value.toInt(), element.b.value.toInt(), element.o.value),
            ),
          )
          .toList();
    });
    updateNotifierDebouncer = debounce(updateOptions, (callback) {
      if (callback == null) return;
      onChanged(callback, dialogContext);
    });
  }

  Map<int, Widget> get segments {
    final map = <int, Widget>{};
    for (int i = 0; i < options.length; i++) {
      map.addEntries([
        MapEntry(
            i,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(options[i].label),
            ))
      ]);
    }
    return map;
  }

  void segmentChanged(int value) {
    if (selectedIndex == value) return;
    selectedIndex = value;
    update();
  }

  saveToggled(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop(true);
  }
}

extension Colorextension on Color {
  Color invertColor() {
    return Color.fromARGB(
      alpha,
      255 - red,
      255 - green,
      255 - blue,
    );
  }

  Color toBlackOrWhite() {
    int luminance = (0.3 * red + 0.59 * green + 0.11 * blue).round();
    return (luminance > 128) ? Color.fromARGB(alpha, 255, 255, 255) : Color.fromARGB(alpha, 0, 0, 0);
  }
}
