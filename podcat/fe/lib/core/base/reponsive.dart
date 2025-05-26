// import 'package:flutter/material.dart';

// class Responsive {
//   // Instance để truy cập các thuộc tính
//   final BuildContext context;
//   late final double width;
//   late final double height;
//   late final double diagonal;
//   late final bool isMobile;
//   late final bool isTablet;
//   late final bool isDesktop;

//   // Breakpoints cho các loại thiết bị
//   static const double mobileBreakpoint = 600;
//   static const double tabletBreakpoint = 900;

//   Responsive(this.context) {
//     final size = MediaQuery.of(context).size;
//     width = size.width;
//     height = size.height;
//     diagonal = size.width * size.width + size.height * size.height;
//     isMobile = width < mobileBreakpoint;
//     isTablet = width >= mobileBreakpoint && width < tabletBreakpoint;
//     isDesktop = width >= tabletBreakpoint;
//   }

//   // Trả về giá trị tỷ lệ theo chiều rộng
//   double widthPercentage(double percentage) {
//     return width * (percentage / 100);
//   }

//   // Trả về giá trị tỷ lệ theo chiều cao
//   double heightPercentage(double percentage) {
//     return height * (percentage / 100);
//   }

//   // Trả về giá trị tỷ lệ dựa trên kích thước chuẩn (ví dụ: 375x812 là kích thước iPhone X)
//   double scaleWidth(double size, {double baseWidth = 375}) {
//     return (size / baseWidth) * width;
//   }

//   double scaleHeight(double size, {double baseHeight = 812}) {
//     return (size / baseHeight) * height;
//   }

//   // Trả về padding responsive
//   EdgeInsets padding({
//     double all = 0,
//     double horizontal = 0,
//     double vertical = 0,
//     double left = 0,
//     double right = 0,
//     double top = 0,
//     double bottom = 0,
//   }) {
//     return EdgeInsets.only(
//       left: scaleWidth(left == 0 ? (all == 0 ? horizontal : all) : left),
//       right: scaleWidth(right == 0 ? (all == 0 ? horizontal : all) : right),
//       top: scaleHeight(top == 0 ? (all == 0 ? vertical : all) : top),
//       bottom: scaleHeight(bottom == 0 ? (all == 0 ? vertical : all) : bottom),
//     );
//   }

//   // Trả về font size responsive
//   double fontSize(double size) {
//     return scaleWidth(size);
//   }

//   // Trả về kích thước dựa trên loại thiết bị
//   T adaptiveValue<T>({
//     required T mobile,
//     required T tablet,
//     required T desktop,
//   }) {
//     if (isDesktop) return desktop;
//     if (isTablet) return tablet;
//     return mobile;
//   }

//   // Phương thức tĩnh để sử dụng mà không cần instance
//   static Responsive of(BuildContext context) => Responsive(context);
// }
