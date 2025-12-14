import 'package:get/get.dart';

import '../export_controllers.dart';

class VerificationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerificationController());
  }
}
