class StringConst {
  static final StringConst _instance = StringConst._internal();

  StringConst._internal();

  static StringConst get instance => _instance;

  static const String appName = 'Flutter Toolkit';
  static const String welcomeText = 'Welcome to the app!';
  static const String login = 'Login';

  //No Internet
  static const String noInternet = 'No Internet Connection Found!';
  static const String pleaseEnableYourInterNet = 'Please enable your internet';

  //Authentication validations
  static const String emptyEmail = 'Please enter your email address';
  static const String errorInvalidEmail = 'Please enter valid email address';
  static const String errorInvalidPassword = 'Password must be at least 8 characters, at least 1 upper case letter, at least 1 lower case letter, at least 1 number, at least 1 special characters';
  static const String errorInvalidConfirmPassword = 'Password does not matched';
  static const String emptyPassword = 'Please enter your password';
  static const String emptyConfirmPassword = 'Please enter your confirm password';
  static const String errorEnterAtLeastTwoCharacter = 'Please enter at least 2 characters';
  static const String errorInvalidLengthFirstName = 'First name must be at most 35 characters long';
  static const String errorInvalidLengthLastName = 'Last name must be at most 35 characters long';
  static const String emptyFirstName = 'Please enter your first name';
  static const String emptyVesselName = 'Please enter your vessel name';
  static const String emptyCaptainName = 'Please enter your captain name';

  static const String emptyLastName = 'Please enter your last name';
  static const String emptyVehicleType = 'Please select vehicle type';
  static const String errorNoDigitsAllowed = 'cannot contain digits.';
  static const String errorNoSpecialCharacters = ' cannot contain special characters.';
  static const String passwordsDoNotMatchError = 'The password you entered doesn’t match';
  static const String incorrectCodeError = 'The code you entered is incorrect. Please try again.';
  static const String emptySubject = 'Please enter your Subject Name';
  static const String emptyDescription = 'Please enter your Description';
  static const emptyOtp = 'Please enter OTP';
  static const otpLength = 'Please enter 6 digit OTP';
  static const String errorNoMoreThan35Characters = 'must be at most 35 characters long';
  static const String pleaseAccept = 'Please agree to the Terms, Privacy Policy, and Safety Disclaimer to continue.';
  static const String imagesOver10MB = 'Images over 10MB cannot be uploaded.';

  //Card Validation
  static const String invalidCardLength = 'Invalid card Number';
  static const String emptyCardNumber = 'Please enter your Card Number';
  static const String emptyCvvNumber = 'Please enter your CVV Number';
  static const String errorCardNumberOnlyDigits = 'Contain only digits.';
  static const String errorInvalidLengthCVVNumber = 'Card Number must be at most 3 characters long';
  static const String emptyCardHolderName = 'Please enter your card holder name';
  static const String emptyExpiration = "Please enter a Expiration.";
  static const String invalidExpiration = 'Invalid expiration date format. Use /YY';

  //=================================== LogIn =========================//

  static const String logInSecurely = 'Login Securely';
  static const String accessYourAccount = 'Access your account using the credentials shared on your registered email id';
  static const String registeredEmailAddress = 'Registered Email Address';
  static const String email = 'Email';
  static const String enterEmail = 'Enter Email';
  static const String emailHint = 'adminpacificfishiries@gmail.com';
  static const String password = 'Password';
  static const String passwordHint = 'Avcdw@782';
  static const String forgotPassword = 'Forgot Password ?';
  static const String forgotPassword1 = 'Forgot Password';
  static const String logIn = 'LOGIN';
  static const String or = 'OR';
  static const String google = 'Google';
  static const String apple = 'Apple';
  static const String addVessel = 'ADD VESSEL';
  static const String addYourVessel = 'ADD YOUR VESSEL';
  static const String addNewTrip = 'ADD New TRIP';
  static const String startTrip = 'START TRIP';

  //=================================== Signup =========================//

  static const String doNotHaveAnAccount = 'Don’t have an account? ';
  static const String signUp = 'Sign Up';
  static const String createPassword = 'Create Password';
  static const String fullName = 'Full Name';
  static const String enterFullName = 'Enter Full Name';
  static const String enterCreatePassword = 'Enter Create Password';
  static const String iAgree = 'I agree to the Terms, Privacy Policy & Safety Disclaimer.';
  static const String country = 'Country';

  //=================================== Verify Otp =========================//
  static const String enterOTP = 'Enter OTP';
  static const String verifyYourIdentity = 'Verify Your Identity';
  static const String enterTheDigitCode = 'Enter the 6-digit code sent to your Email';
  static const String verify = 'VERIFY';
  static const String resendOTP = 'Resend OTP';

  //=================================== Reset Password =========================//
  static const String resetPassword = 'Reset Password';
  static const String continueText = 'CONTINUE';
  static const String confirmPassword = 'Confirm Password';

  //=================================== Forget Password =========================//
  static const String byProceedingYouConsentToGetAlls =
      'By proceeding, you consent to get calls, SMS messages, and emails from us and our affiliates to the provided number or email. You can opt out anytime.';
  static const String sendCode = 'SEND CODE';

  //=================================== Vessel Detail =========================//
  static const String viewAllTrip = 'VIEW ALL TRIP LOGS';

  //=================================== Add new vessel =========================//
  static const String addNewTrip1 = 'Add New Trip';
  static const String addNewVessel = 'Add New Vessel';
  static const String vesselName = "Vessel Name";
  static const String vesselNameHint = "ex- The Pacific Queen";
  static const String vesselId = 'Vessel ID';
  static const String vesselIdHint = 'JG875NM9';
  static const String selectVesselType = 'Select Vessel Type';
  static const String vesselTypeHint = 'ex- Carrie, RORO, Tanker';
  static const String assignCaptain = 'Assign Captain';
  static const String assignCaptainHit = 'ex- Harry Thompson';
  static const String emergencyContact = 'Emergency Contact';

  static const String carrier = 'Carrier';
  static const String passenger = 'Passenger';
  static const String roroVessel = 'RORO vessel';
  static const String tanker = 'Tanker';
  static const String fishing = 'Fishing';
  static const String reeferShips = 'Reefer Ships';
  static const String liveStock = 'Live Stock';
  static const String tugboat = 'Tugboat';
  static const String from = 'From';
  static const String to = 'To';

  //=================================== Add new trip =========================//

  static const String startFrom = 'Start From';
  static const String exPanamaPoint = 'ex - Panama Point (PPO)';
  static const String destination = 'Destination';
  static const String exLondonBay = 'ex - London Bay (LBA)';
  static const String startDate = 'Start Date';
  static const String estimatedArrivalDate = 'Estimated Arrival Date';
  static const String date = '12/06/2025';

  static const String pleaseUploadOrTake = 'Please upload or take a photo.';

  // ====================== camera and gallery permission ==================== //
  static const String cameraPermission = 'Camera Permission';
  static const String cameraDescription = 'Camera permission should Be granted to use this feature, would you like to go to app settings to give camera permission?';
  static const String photoPermission = 'Photos Permission';
  static const String photoDescription = 'Photos permission should Be granted to use this feature, would you like to go to app settings to give photos permission?';

  static const String chooseFromGallery = "Choose from gallery";
  static const String takePhoto = "Take Photo";
  static const String changeProfilePicture = "Change Profile picture";
}
