import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IOSFeatureComponent extends StatelessWidget {
  const IOSFeatureComponent({super.key, required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return WhatsNewFeature(
      icon: Icon(icon, color: CupertinoColors.systemBlue.resolveFrom(context)),
      title: Text(title),
      description: Text(description),
    ).bounce(end: 0, begin: 0.15);
  }
}
