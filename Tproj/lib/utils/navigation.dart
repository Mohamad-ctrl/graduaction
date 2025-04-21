// File: lib/utils/navigation.dart
import 'package:flutter/material.dart';

class NavigationUtils {
  // Navigate to a new screen
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Navigate to a new screen and remove all previous screens
  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Navigate to a new screen and replace the current screen
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Go back to previous screen
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  // Show a dialog
  static Future<T?> showCustomDialog<T>(BuildContext context, Widget dialog) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  // Show a bottom sheet
  static Future<T?> showCustomBottomSheet<T>(BuildContext context, Widget bottomSheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return bottomSheet;
      },
    );
  }
}
