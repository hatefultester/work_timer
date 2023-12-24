import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/views/ios_history_view.dart';
import 'package:work_timer/ios/views/ios_settings_view.dart';
import 'package:work_timer/ios/views/ios_today_view.dart';
import 'package:work_timer/shared/ui_kit/extensions/controller.dart';
import 'package:work_timer/shared/ui_kit/ios/components/ios_header_component.dart';
import 'package:work_timer/shared/ui_kit/ios/layouts/ios_view_layout.dart';

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
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'History'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.today), label: 'Today'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) => IOSViewLayout(
          content: switch (index) {
            0 => const IOSHistoryView(),
            1 => const IOSTodayView(),
            _ => const IOSSettingsView(),
          },
          header: IOSHeaderComponent(
            title: switch (index) { 0 => 'History', 1 => 'Today', _ => 'Settings' },
            onMorePressed: controller.onMoreIconPressed,
          ),
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
