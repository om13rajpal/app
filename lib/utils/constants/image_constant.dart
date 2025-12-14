class ImageConst {
  static final ImageConst _instance = ImageConst._internal();

  ImageConst._internal();

  static ImageConst get instance => _instance;

  static const String images = 'assets/images/';
  static const String icons = 'assets/icons/';
  static const String gif = 'assets/gif/';

  static const String appLogoPng = '${images}logo.png';
  static const String logInBg = '${images}logIn_bg.png';

  static const String appleSvg = '${icons}apple.svg';
  static const String googleSvg = '${icons}google.svg';
  static const String vesselSvg = '${icons}vessel.svg';
  static const String captainHatSvg = '${icons}captain_hat.svg';

  static const String fishSvg = '${icons}fish.svg';
  static const String tempSvg = '${icons}temp.svg';
  static const String goatSvg = '${icons}goat.svg';
  static const String boattugSvg = '${icons}boattug.svg';
  static const String arrowRight = '${icons}arrowRight.svg';
  static const String boat = '${icons}boat.svg';
  static const String direction = '${icons}direction.svg';
  static const String location = '${icons}location.svg';
  static const String radio = '${icons}radio.svg';
  static const String trip = '${icons}trip.svg';
  static const String alert = '${icons}alert.svg';
  static const String flash = '${icons}flash.svg';
  static const String course = '${icons}course.svg';
  static const String crewMembers = '${icons}crewMembers.svg';
  static const String clock = '${icons}clock.svg';
  static const String severity = '${icons}severity.svg';
  static const String type = '${icons}type.svg';
  static const String report = '${icons}report.svg';
  static const String distanceTravelled = '${icons}distanceTravelled.svg';
  static const String distanceToGo = '${icons}distanceToGo.svg';
  static const String draught = '${icons}draught.svg';
  static const String weather1 = '${icons}weather1.svg';
  static const String windSpeed = '${icons}windSpeed.svg';
  static const String fuel = '${icons}fuel.svg';
  static const String country = '${icons}country.svg';

  static const String weather = '${images}weather.png';

  static const String gallerySvg = '${icons}gallery.svg';
  static const String camera = '${icons}camera.svg';
  static const String userPlaceHolder = '${images}userPlaceHolder.png';
}
