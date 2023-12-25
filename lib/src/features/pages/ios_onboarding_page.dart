import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/features/pages/ios_home_page.dart';
import 'package:work_timer/src/ui_kit/ios/ios_feature_component.dart';
import 'package:work_timer/src/ui_kit/ios/ios_slide_transition_builder.dart';
import 'package:work_timer/src/data/config/storage.dart';
import 'package:work_timer/src/ui_kit/shared/animations.dart';

import '../../data/config/keys.dart';
import '../../ui_kit/ios/ios_new_features_layout.dart';

class IOSOnboardingPage extends StatelessWidget {
  const IOSOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSOnboardingController>(
      init: IOSOnboardingController(),
      builder: (controller) => IOSNewFeaturesLayout(
        title: const Text('Tracking made easy'),
        features: const [
          IOSFeatureComponent(
            icon: CupertinoIcons.time,
            title: 'Set your daily work limit',
            description: 'Set limit to see how you progress during a day',
          ),
          IOSFeatureComponent(
            icon: CupertinoIcons.book,
            title: 'Write down what you need to do',
            description: 'Set task for your day',
          ),
          IOSFeatureComponent(
            icon: CupertinoIcons.device_laptop,
            title: 'Connect with multiple devices',
            description: 'Track and update progress on multiple devices',
          ),
        ],
        buttonLabel: const Text('Continue'),
        onButtonPressed: controller.onSubmitPressed,
      ).triggeredFadeOut(
        controller.fadeOutAnimationTrigger ?? false,
        duration: 3.seconds,
      ),
    );
  }
}

class IOSOnboardingController extends GetxController {
  late bool? fadeOutAnimationTrigger;

  @override
  onInit() {
    super.onInit();
    fadeOutAnimationTrigger = false;
  }

  @override
  onClose() {
    super.onClose();
    fadeOutAnimationTrigger = null;
  }

  onSubmitPressed(BuildContext context) async {
    final navigator = Navigator.of(context);
    fadeOutAnimationTrigger = true;
    update();
    await storage.write(StorageKey.hasSeenOnboarding, true);
    await storage.save();
    navigator.pushReplacement(IOSSlidePageBuilder(page: const IOSHomePage()));
  }
}
