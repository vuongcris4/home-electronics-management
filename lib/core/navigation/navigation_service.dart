// lib/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

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