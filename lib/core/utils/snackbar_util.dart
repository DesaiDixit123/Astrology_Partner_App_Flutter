import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarUtil {
  static void show({
    required String message,
    required SnackbarType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (message.trim().isEmpty) return;
    final config = _getConfig(type);

    // Cancel any active toast and display ONLY ONE single clean toast
    try {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: config.backgroundColor,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (_) {}
  }

  static void success(String message, {String? title}) {
    show(message: message, type: SnackbarType.success, title: title);
  }

  static void error(String message, {String? title}) {
    show(message: message, type: SnackbarType.error, title: title);
  }

  static void warning(String message, {String? title}) {
    show(message: message, type: SnackbarType.warning, title: title);
  }

  static void info(String message, {String? title}) {
    show(message: message, type: SnackbarType.info, title: title);
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          title: 'Success',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          title: 'Error',
          icon: Icons.error,
          backgroundColor: AppColors.error,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          title: 'Warning',
          icon: Icons.warning,
          backgroundColor: AppColors.warning,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          title: 'Info',
          icon: Icons.info,
          backgroundColor: AppColors.info,
        );
    }
  }
}

class _SnackbarConfig {
  final String title;
  final IconData icon;
  final Color backgroundColor;

  _SnackbarConfig({
    required this.title,
    required this.icon,
    required this.backgroundColor,
  });
}
