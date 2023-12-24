import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_timer/ios/views/ios_history_view.dart';
import 'package:work_timer/ios/views/ios_settings_view.dart';
import 'package:work_timer/ios/views/ios_today_view.dart';
import 'package:work_timer/ios/widgets/components/ios_header_component.dart';
import 'package:work_timer/ios/widgets/layouts/ios_view_layout.dart';
import 'package:work_timer/shared/service/logger.dart';

import '../../shared/ui/gap.dart';

class IOSHomePage extends StatelessWidget {
  const IOSHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSHomePageController>(
      init: IOSHomePageController(),
      builder: (controller) => SafeArea(
        child: CupertinoTabScaffold(
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
            header: const IOSHeaderComponent(),
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
}
