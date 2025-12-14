import 'package:aiSeaSafe/utils/constants/global_variable.dart';
import 'package:aiSeaSafe/utils/constants/string_constant.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/preferences_services.dart';
import 'widgets/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase if needed
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize shared preferences
  await AppSharedPreference.init();
  // NotificationDelegate.initialize();
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Set system UI overlay style (status bar color, icon brightness, etc.)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark));

  runApp(
    MyApp(),
    // Builder(
    //   builder: (context) {
    //     final view = View.of(context);
    //     return MediaQuery(
    //       data: MediaQueryData.fromView(view).copyWith(textScaler: TextScaler.linear(1.0)),
    //       child: const ,
    //     );
    //   },
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(402, 874), //make according your figma design
      builder: (context, child) {
        return GetMaterialApp(
          navigatorKey: apNavigatorKey,
          localizationsDelegates: [CountryLocalizations.delegate],
          debugShowCheckedModeBanner: false,
          title: StringConst.appName,
          theme: AppTheme.light.copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
          initialRoute: Routes.onboarding,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
