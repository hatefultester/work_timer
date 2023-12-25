import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/features/views/ios_history_view.dart';
import 'package:work_timer/src/features/views/ios_settings_view.dart';
import 'package:work_timer/src/features/views/ios_today_view.dart';
import 'package:work_timer/src/ui_kit/shared/controller.dart';
import 'package:work_timer/src/ui_kit/ios/ios_header_component.dart';
import 'package:work_timer/src/ui_kit/ios/ios_view_layout.dart';

class IOSHomePage extends StatelessWidget {
  const IOSHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSHomePageController>(
      init: IOSHomePageController(),
      builder: (controller) => CupertinoTabScaffold(
        controller: controller.tabController,
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.book)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.today)),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid)),
          ],
        ),
        tabBuilder: (BuildContext context, int index) => IOSViewLayout(
          header: IOSHeaderComponent(
            title: switch (index) {
              0 => 'History',
              1 => 'Today',
              _ => 'Settings',
            },
            onMorePressed: controller.onMoreIconPressed,
          ),
          content: switch (index) {
            0 => const IOSHistoryView(),
            1 => const IOSTodayView(),
            _ => const IOSSettingsView(),
          },
        ),
      ),
    );
  }
}

class IOSHomePageController extends GetxController {
  late CupertinoTabController tabController;

  @override
  onInit() {
    super.onInit();
    tabController = CupertinoTabController(initialIndex: 1);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  onMoreIconPressed(BuildContext context) async {
    await showIOSModalPopUp(context, actions: const [
      IOSActionData(label: 'Help'),
      IOSActionData(label: 'Report issue', isDestructive: true),
      IOSActionData(label: 'About up', isDefault: true),
    ], onResultHandler: (indexSelected, context) async {
      if (indexSelected == null) return;
    });
  }
}
