import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/pages/ios_onboarding_page.dart';
import 'package:work_timer/shared/service/storage.dart';
import '../shared/config/keys.dart';
import 'pages/ios_home_page.dart';

class IOSApp extends StatelessWidget {
  const IOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSAppController>(
      init: IOSAppController(),
      builder: (controller) {
        return CupertinoApp(
          localizationsDelegates: const [
            DefaultCupertinoLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          onGenerateTitle: (_) => 'Track your time',
          theme: CupertinoThemeData(
            brightness: controller.brightness,
            barBackgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
            primaryColor: controller.brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black,
          ),
          home: controller.hasSeenOnboardingAlready ? const IOSHomePage() : const IOSOnboardingPage(),
        );
      },
    );
  }
}

class IOSAppController extends GetxController {
  static IOSAppController get to => Get.find();
  late bool hasSeenOnboardingAlready;
  late Brightness brightness;

  @override
  void onInit() {
    super.onInit();
    fetchDataFromStorage();
  }

  fetchDataFromStorage() {
    final brightnessIndex = storage.read<int?>(StorageKey.brightnessIndex);
    hasSeenOnboardingAlready = storage.read<bool?>(StorageKey.hasSeenOnboarding) ?? false;
    brightness = Brightness.values[brightnessIndex ?? 0];
  }

  toggleApplicationBrightness([_]) async {
    brightness = brightness == Brightness.light ? Brightness.dark : Brightness.light;
    storage.write(StorageKey.brightnessIndex, brightness.index);
    await storage.save();
    update();
  }

  void restart() {
    fetchDataFromStorage();
    update();
  }
}
