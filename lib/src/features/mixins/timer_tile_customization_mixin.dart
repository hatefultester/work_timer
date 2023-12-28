import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';

mixin TileCustomizationMixin on GetxController {
  Rx<Color>? _workDurationBackgroundTileColor;
  static const String workDurationBackgroundTileColorKey = 'work-duration-background-tile-color';

  Rx<Color> get workDurationBackgroundTileColor => _workDurationBackgroundTileColor!;

  Rx<Color>? _workDurationProgressColor;
  static const String workDurationProgressColorKey = 'work-duration-progress-color';

  Rx<Color> get workDurationProgressColor => _workDurationProgressColor!;

  Rx<Color>? _taskBackgroundTileColor;
  static const String taskBackgroundTileColorKey = 'task-background-tile-color';

  Rx<Color> get taskBackgroundTileColor => _taskBackgroundTileColor!;
  Rx<Color>? _taskProgressColor;
  static const String taskProgressColorKey = 'task-progress-color';

  Rx<Color> get taskProgressColor => _taskProgressColor!;

  initTileCustomizationResources(BuildContext context) {
    final workDurationBackgroundTileColorJson = storage.read<String?>(workDurationBackgroundTileColorKey);
    final workDurationProgressColorJson = storage.read<String?>(workDurationProgressColorKey);
    final taskBackgroundTileColorJson = storage.read<String?>(taskBackgroundTileColorKey);
    final taskProgressColorJson = storage.read<String?>(taskProgressColorKey);

    final workBackgroundColor = ColorJson.fromJson(workDurationBackgroundTileColorJson) ??
        CupertinoColors.systemGroupedBackground.resolveFrom(context);
    final workProgressColor =
        ColorJson.fromJson(workDurationProgressColorJson) ?? CupertinoColors.activeBlue.resolveFrom(context);
    _workDurationBackgroundTileColor = (Color.fromRGBO(
            workBackgroundColor.red, workBackgroundColor.green, workBackgroundColor.blue, workBackgroundColor.opacity))
        .obs;
    _workDurationProgressColor = (Color.fromRGBO(
            workProgressColor.red, workProgressColor.green, workProgressColor.blue, workProgressColor.opacity))
        .obs;

    final taskBackgroundColor =
        ColorJson.fromJson(taskBackgroundTileColorJson) ?? CupertinoColors.systemGroupedBackground.resolveFrom(context);
    final taskProgressColor =
        ColorJson.fromJson(taskProgressColorJson) ?? CupertinoColors.activeBlue.resolveFrom(context);
    _taskBackgroundTileColor = (Color.fromRGBO(
            taskBackgroundColor.red, taskBackgroundColor.green, taskBackgroundColor.blue, taskBackgroundColor.opacity))
        .obs;
    _taskProgressColor = (Color.fromRGBO(
            taskProgressColor.red, taskProgressColor.green, taskProgressColor.blue, taskProgressColor.opacity))
        .obs;
  }

  disposeTileCustomizationResources() {
    _workDurationBackgroundTileColor?.dispose();
    _workDurationProgressColor?.dispose();
    _workDurationBackgroundTileColor = null;
    _workDurationProgressColor = null;

    _taskBackgroundTileColor?.dispose();
    _taskProgressColor?.dispose();
    _taskBackgroundTileColor = null;
    _taskProgressColor = null;
  }

  void customizeWorkingHoursTile(BuildContext context) async {
    await showIOSColorCustomizationBottomSheet(context, options: [
      IOSColorCustomizationBottomSheetOption(
        label: 'Background',
        value: workDurationBackgroundTileColor.value,
      ),
      IOSColorCustomizationBottomSheetOption(
        label: 'Progress color',
        value: workDurationProgressColor.value,
      ),
    ], onChanged: (updatedList, context) async {
      if (!context.mounted) return;
      workDurationBackgroundTileColor.value = updatedList[0].value;
      workDurationProgressColor.value = updatedList[1].value;
    }, onClosed: (context, originalOptions, wasSaved) async {
      if (wasSaved) {
        showIOSLoadingOverlay(context);
        await storage.write(workDurationBackgroundTileColorKey, jsonEncode(workDurationBackgroundTileColor.value.toJson()));
        await storage.write(workDurationProgressColorKey, jsonEncode(workDurationProgressColor.value.toJson()));
        await hideIOSLoadingOverlay();
      } else {
        workDurationBackgroundTileColor.value = originalOptions[0].value;
        workDurationProgressColor.value = originalOptions[1].value;
      }
    });
  }

  void customizeTasksTile(BuildContext context) async {
    await showIOSColorCustomizationBottomSheet(
      context,
      options: [
        IOSColorCustomizationBottomSheetOption(
          label: 'Background',
          value: taskBackgroundTileColor.value,
        ),
        IOSColorCustomizationBottomSheetOption(
          label: 'Progress color',
          value: taskProgressColor.value,
        ),
      ],
      onChanged: (updatedList, context) async {
        if (!context.mounted) return;
        taskBackgroundTileColor.value = updatedList[0].value;
        taskProgressColor.value = updatedList[1].value;
      },
      onClosed: (context, originalOptions, wasSaved) async {
        if (wasSaved) {
          showIOSLoadingOverlay(context);
          await storage.write(taskBackgroundTileColorKey, jsonEncode(taskBackgroundTileColor.value.toJson()));
          await storage.write(taskProgressColorKey, jsonEncode(taskProgressColor.value.toJson()));
          await hideIOSLoadingOverlay();
        } else {
          taskBackgroundTileColor.value = originalOptions[0].value;
          taskProgressColor.value = originalOptions[1].value;
        }
      },
    );
  }
}

extension ColorJson on Color {
  Map<String, dynamic> toJson() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'opacity': opacity,
    };
  }

  static Color? fromJson(dynamic data) {
    try {
      final json = jsonDecode(data);
      if (json.containsKey('red') &&
          json.containsKey('green') &&
          json.containsKey('blue') &&
          json.containsKey('opacity')) {
        return Color.fromRGBO(
          json['red'] as int,
          json['green'] as int,
          json['blue'] as int,
          json['opacity'] as double,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
