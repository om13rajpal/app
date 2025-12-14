import 'dart:developer';

class LoggerHelper {
  static void logInfo(String message) => log("[INFO] $message");
  static void logError(String message, [Object? error]) =>
      log("[ERROR] $message", error: error);
}
