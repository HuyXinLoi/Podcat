import 'package:flutter/material.dart';
import 'package:podcat/core/utils/constants.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width <= ResponsiveBreakpoints.mobileMax) {
      return DeviceType.mobile;
    } else if (width <= ResponsiveBreakpoints.tabletMax) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  static double getCardWidth(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return MediaQuery.of(context).size.width * 0.42;
      case DeviceType.tablet:
        return 180;
      case DeviceType.desktop:
        return 220;
    }
  }

  static double getCardHeight(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return MediaQuery.of(context).size.width * 0.42;
      case DeviceType.tablet:
        return 180;
      case DeviceType.desktop:
        return 220;
    }
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    DeviceType deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.1;
      case DeviceType.desktop:
        return baseFontSize * 1.2;
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  static Widget buildResponsiveGridView({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
  }) {
    DeviceType deviceType = getDeviceType(context);
    int crossAxisCount;

    switch (deviceType) {
      case DeviceType.mobile:
        crossAxisCount = 2;
        break;
      case DeviceType.tablet:
        crossAxisCount = 3;
        break;
      case DeviceType.desktop:
        crossAxisCount = 4;
        break;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: children.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => children[index],
    );
  }
}
