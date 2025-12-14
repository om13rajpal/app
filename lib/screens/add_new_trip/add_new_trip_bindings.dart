import 'package:get/get.dart';

import '../export_controllers.dart';

class AddNewTripBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddNewTripController());
  }
}
