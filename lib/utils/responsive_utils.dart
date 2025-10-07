import 'package:flutter/material.dart';

// Responsive utilities for the app
class ResponsiveUtils {
  // Get screen size breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // FAB positioning utilities
  static double getFabLeftPosition(BuildContext context, double fabSize) {
    return getScreenWidth(context) / 2 - (fabSize / 2);
  }

  // Navigation bar positioning
  static EdgeInsets getNavBarPadding(BuildContext context) {
    return const EdgeInsets.only(bottom: 16, left: 16, right: 16);
  }

  // Card spacing based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Text scaling based on screen size
  static double getScaledTextSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  // Icon scaling based on screen size
  static double getScaledIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  // Grid layout utilities
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  // Spacing utilities
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.5;
    } else {
      return baseSpacing * 2;
    }
  }
}
