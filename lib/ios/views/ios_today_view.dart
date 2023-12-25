import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IOSTodayView extends StatelessWidget {
  const IOSTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IOSTodayController>(
        init: IOSTodayController(),
        builder: (controller) {

        });
  }
}

class IOSTodayController extends GetxController {



  @override
  void onInit() {
    super.onInit();
  }
}