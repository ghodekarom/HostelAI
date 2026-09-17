import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'routes.dart';
import 'theme.dart';

/// Multiplatform ScrollBehavior enabling seamless drag-to-scroll with mouse,
/// trackpad, stylus, and touch across Web, Desktop (Windows/macOS/Linux), and Mobile.
class HfcmsScrollBehavior extends MaterialScrollBehavior {
  const HfcmsScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class HfcmsApp extends StatelessWidget {
  const HfcmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const HfcmsScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
