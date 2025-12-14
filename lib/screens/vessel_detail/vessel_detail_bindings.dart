import 'package:aiSeaSafe/screens/export_controllers.dart';
import 'package:get/get.dart';

class VesselDetailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VesselDetailController());
  }
}
