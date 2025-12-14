import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {
  AppSharedPreference._();

  static final AppSharedPreference _instance = AppSharedPreference._();
  static SharedPreferences? _shared;

  final String _isLogged = 'isLogged';
  final String _token = 'token';
  final String _userId = 'userId';
  final String _isGuestUser = 'isGuestUser';
  final String _isActive = 'isActive';
  final String _roomId = 'roomId';

  set isLogged(bool value) => _shared?.setBool(_isLogged, value);
  bool get isLogged => _shared?.getBool(_isLogged) ?? false;

  set isGuestUser(bool value) => _shared?.setBool(_isGuestUser, value);
  bool get isGuestUser => _shared?.getBool(_isGuestUser) ?? false;

  set token(String? value) {
    if (value == null) return;
    _shared?.setString(_token, value);
  }

  String? get roomId => _shared?.getString(_roomId);
  set roomId(String? value) {
    if (value == null) return;
    _shared?.setString(_roomId, value);
  }

  String? get token => _shared?.getString(_token);

  set userId(String? value) {
    if (value == null) return;
    _shared?.setString(_userId, value);
  }

  String? get userId => _shared?.getString(_userId);

  set isActive(bool value) => _shared?.setBool(_isActive, value);
  bool get isActive => _shared?.getBool(_isActive) ?? false;

  static Future<void> init() async {
    _shared = await SharedPreferences.getInstance();
  }

  Future<void> clear() async {
    await _shared?.remove(_isLogged);
    await _shared?.remove(_token);
    await _shared?.remove(_isGuestUser);
    await _shared?.remove(_isActive);
    await _shared?.remove(_userId);
    await _shared?.remove(_roomId);
  }

  static AppSharedPreference get instance => _instance;
}
