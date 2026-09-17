import 'package:flutter/foundation.dart';

/// Multiplatform utility for determining client execution environment
/// across Web, Mobile (Android/iOS), and Desktop (Windows/macOS/Linux).
class PlatformUtils {
  PlatformUtils._();

  /// True when running on Web platform (browsers)
  static bool get isWeb => kIsWeb;

  /// True when running on Android or iOS mobile devices
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// True when running on Windows, macOS, or Linux desktop environments
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Target platform name for logging or telemetry
  static String get platformName {
    if (kIsWeb) return 'Web Client';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android Mobile';
      case TargetPlatform.iOS:
        return 'iOS Mobile';
      case TargetPlatform.windows:
        return 'Windows Desktop';
      case TargetPlatform.macOS:
        return 'macOS Desktop';
      case TargetPlatform.linux:
        return 'Linux Desktop';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }
}
