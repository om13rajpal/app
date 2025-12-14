import 'package:aiSeaSafe/screens/add_new_trip/add_new_trip_bindings.dart';
import 'package:aiSeaSafe/screens/add_new_trip/add_new_trip_view.dart';
import 'package:aiSeaSafe/screens/export_bindings.dart';
import 'package:aiSeaSafe/screens/export_views.dart';
import 'package:aiSeaSafe/screens/onboarding/onboarding_view.dart';
import 'package:aiSeaSafe/screens/voice_dialog/voice_dialog_bindings.dart';
import 'package:aiSeaSafe/screens/voice_dialog/voice_dialog_view.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

/// Application pages configuration.
///
/// This class defines all routes and their associated pages and bindings.
/// Each GetPage entry maps a route name to its corresponding view and
/// dependency bindings.
class AppPages {
  static final routes = [
    GetPage(name: Routes.home, page: () => HomeView(), binding: HomeBinding()),
    GetPage(name: Routes.login, page: () => LoginView(), binding: LoginBindings()),
    GetPage(name: Routes.signUp, page: () => SignupView(), binding: SignupBindings()),

    GetPage(name: Routes.addVessel, page: () => AddVesselView(), binding: AddVesselBindings()),
    GetPage(name: Routes.addNewTrip, page: () => AddNewTripView(), binding: AddNewTripBindings()),

    GetPage(name: Routes.onboarding, page: () => BoatScene()),
    GetPage(name: Routes.vesselDetail, page: () => VesselDetailView(), binding: VesselDetailBindings()),
    GetPage(name: Routes.forgetPassword, page: () => ForgetPasswordView(), binding: ForgetPasswordBindings()),
    GetPage(name: Routes.verification, page: () => VerificationView(), binding: VerificationBindings()),
    GetPage(name: Routes.resetPassword, page: () => ResetPasswordView(), binding: ResetPasswordBindings()),

    // Voice Assistant Dialog
    GetPage(
      name: Routes.voiceDialog,
      page: () => const VoiceDialogView(),
      binding: VoiceDialogBindings(),
    ),
  ];
}
