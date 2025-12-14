import 'package:get/get.dart';

import '../export_controllers.dart';

class ResetPasswordBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResetPasswordController());
  }
}
