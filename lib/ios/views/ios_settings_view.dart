
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/ios_app.dart';
import 'package:work_timer/ios/pages/ios_onboarding_page.dart';
import 'package:work_timer/shared/service/storage.dart';
import 'package:work_timer/shared/ui_kit/extensions/controller.dart';

class IOSSettingsView extends StatelessWidget {
  const IOSSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSSettingsController>(
      init: IOSSettingsController(),
      builder: (controller) => Column(
        children: [
          CupertinoListSection(
            backgroundColor: Colors.transparent,
            header: const Text('Application settings'),
            margin: const EdgeInsets.all(8),
            children: [
              CupertinoListTile(
                title: const Text('Dark theme'),
                onTap: IOSAppController.to.toggleApplicationBrightness,
                trailing: GetBuilder<IOSAppController>(
                  builder: (controller) => CupertinoSwitch(
                    value: controller.brightness.index == 0,
                    onChanged: controller.toggleApplicationBrightness,
                  ),
                ),
              ),
              CupertinoListTile(
                title: const Text('Restore settings'),
                onTap: () => controller.showRestoreSettingsConfirmationDialog(context),
              )
            ],
          )
        ],
      ),
    );
  }
}

class IOSSettingsController extends GetxController {
  showRestoreSettingsConfirmationDialog(BuildContext context) async {
    await showIOSConfirmationDialog(
      context,
      title: 'Are you sure?',
      description: 'This action will delete everything from your account.',
      onResultHandler: (result, context) async {
        showIOSLoadingOverlay(context);
        final navigator = Navigator.of(context);
        if (!result) {
          if (navigator.canPop()) navigator.pop();
          await hideIOSLoadingOverlay();
          return;
        }

        final keys = storage.getKeys<Iterable<String>>().toList();
        for (final key in keys) {
          await storage.remove(key);
        }
        await storage.erase();
        await hideIOSLoadingOverlay();

        IOSAppController.to.restart();
        navigator.pushReplacement(CupertinoPageRoute(builder: (_) => const IOSOnboardingPage()));
      },
    );
  }
}
