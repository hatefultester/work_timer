import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/shared/ui/context.dart';
import 'package:work_timer/shared/ui/hero.dart';

import '../../../shared/ui/gap.dart';
import '../components/ios_bottom_button_component.dart';

class IOSNewFeaturesLayout extends StatelessWidget {
  const IOSNewFeaturesLayout({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onButtonPressed,
    required this.features,
    this.titleHeroTag,
    this.buttonHeroTag,
  });

  final Widget title;
  final Widget buttonLabel;

  final ContextCallback onButtonPressed;
  final List<Widget> features;

  final String? titleHeroTag;
  final String? buttonHeroTag;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: WhatsNewPage(
              title:title.applyHero(titleHeroTag),
              featuresSeperator: Gap.v32,
              features: features,
            ),
          ),
          IOSBottomButtonComponent(label: buttonLabel, callback: onButtonPressed)
              .applyHero(buttonHeroTag)
              .fadeIn(duration: 2.seconds),
        ],
      ),
    ).fadeIn(duration: 1.seconds);
  }
}
