import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Responsive design helper for cross-platform compatibility
/// This ensures your app works well on iOS, web, and other platforms
class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Check if running on iOS (including web with iOS-like constraints)
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  /// Check if running on web
  static bool isWeb(BuildContext context) {
    return kIsWeb;
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize;
      case DeviceType.tablet:
        return baseSize * 1.1;
      case DeviceType.desktop:
        return baseSize * 1.2;
    }
  }

  /// Get safe area padding for iOS devices
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// Get container constraints for responsive design
  static BoxConstraints getContainerConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isWeb(context)) {
      // For web, limit width to simulate mobile experience
      return BoxConstraints(
        maxWidth: 500,
        maxHeight: screenHeight,
      );
    }

    // For mobile/tablet, use full screen
    return BoxConstraints(
      maxWidth: screenWidth,
      maxHeight: screenHeight,
    );
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Check if device supports landscape orientation
  static bool supportsLandscape(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape;
  }

  /// Get minimum touch target size (iOS requirement: 44pt)
  static double getMinTouchTargetSize() => 44.0;

  /// Check if touch target meets iOS requirements
  static bool meetsTouchTargetRequirements(Size size) {
    return size.width >= getMinTouchTargetSize() &&
        size.height >= getMinTouchTargetSize();
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// iOS-specific design constants
class IOSDesignConstants {
  static const double cornerRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 44.0; // iOS minimum touch target
  static const double iconSize = 24.0;
  static const double spacing = 16.0;

  // iOS color scheme
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray6 = Color(0xFFF2F2F7);
}
