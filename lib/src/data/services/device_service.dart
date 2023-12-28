import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DeviceService extends GetxService {
  static DeviceService get to => Get.find();

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
}