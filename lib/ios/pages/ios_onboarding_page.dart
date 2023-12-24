import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/pages/ios_home_page.dart';
import 'package:work_timer/ios/widgets/components/ios_feature_component.dart';
import 'package:work_timer/ios/widgets/transitions/ios_slide_transition_builder.dart';
import 'package:work_timer/shared/service/storage.dart';
import 'package:work_timer/shared/ui/animations.dart';

import '../../shared/config/keys.dart';
import '../widgets/layouts/ios_new_features_layout.dart';

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
        controller.fadeOutAnimationTrigger,
        duration: 3.seconds,
      ),
    );
  }
}

class IOSOnboardingController extends GetxController {
  late bool fadeOutAnimationTrigger;

  @override
  onInit() {
    super.onInit();
    fadeOutAnimationTrigger = false;
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
