import 'package:get/get.dart';

import 'sp_controller.dart';

class NestedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NestedController());
  }
}
