import 'package:aiSeaSafe/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../data/models/export_model.dart';

class HomeController extends GetxController {
  // Observable to track if user has vessels
  var hasVessels = false.obs;
  var hasTripAdded = false.obs;

  // List to store user's vessels
  var vesselsList = <VesselModel>[].obs;

  // Current selected vessel
  var currentVessel = Rxn<VesselModel>();

  @override
  void onInit() {
    super.onInit();
    // Check if user has vessels when controller initializes
    checkUserVessels();
  }

  // Method to check if user has any vessels
  void checkUserVessels() {
    // This would typically fetch from your API or local storage
    // For now, using mock data - replace with actual implementation
    hasVessels.value = vesselsList.isNotEmpty;
  }

  // Method to add a new vessel
  void addVessel(VesselModel vessel) {
    vesselsList.add(vessel);
    hasVessels.value = true;

    // Set as current vessel if it's the first one
    if (vesselsList.length == 1) {
      currentVessel.value = vessel;
    }

    update();
  }

  // Method to handle navigation based on vessel availability
  void handleAddButtonNavigation() {
    if (hasVessels.value) {
      // User has vessels, navigate to Add New Trip
      Get.toNamed(Routes.addNewTrip)?.then((value) {
        hasTripAdded.value = true;
      });
    } else {
      // User has no vessels, navigate to Add New Vessel
      Get.toNamed(Routes.addVessel)?.then((value) {
        if (value != null) {
          addVessel(value);
        }
      });
    }
  }

  // Method to refresh vessel data (call this when returning from add vessel screen)
  void refreshVessels() {
    checkUserVessels();
    update();
  }

  // Method to select a vessel
  void selectVessel(VesselModel vessel) {
    currentVessel.value = vessel;
    update();
  }
}
