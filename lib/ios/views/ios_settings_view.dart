import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/ios_app.dart';

class IOSSettingsView extends StatelessWidget {
  const IOSSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSSettingsController>(
      init: IOSSettingsController(),
      builder: (controller) => Column(
        children: [
          CupertinoListSection(
            header: Text('Application settings'),
            margin: EdgeInsets.all(8),

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
                
              )
            ],
          )
        ],
      ),
    );
  }
}

class IOSSettingsController extends GetxController {}
