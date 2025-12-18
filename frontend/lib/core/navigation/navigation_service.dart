// lib/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';

// cần NavigationService vì getIt không có context
class NavigationService {
  // gắn navigatorKey vào Home Screen
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Chuyển đến màn hình routeName với tham số arguments
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  // Xoá các màn hình và trả về tới khi login
  Future<dynamic>? pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
      arguments: arguments,
    );
  }

  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}