import 'package:get/get.dart';

import '../export_controllers.dart';

class AddVesselBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddVesselController());
  }
}
