/// Application route constants.
///
/// This abstract class contains all named routes used for navigation
/// throughout the application. Using constants ensures type safety
/// and prevents typos in route names.
abstract class Routes {
  static const home = '/home';
  static const login = '/login';
  static const signUp = '/signUp';
  static const forgetPassword = '/forgetPassword';
  static const verification = '/verification';
  static const resetPassword = '/resetPassword';
  static const addVessel = '/addVessel';
  static const addNewTrip = '/addNewTrip';
  static const onboarding = '/onboarding';
  static const vesselDetail = '/vesselDetail';

  /// Voice assistant dialog route
  static const voiceDialog = '/voiceDialog';
}
