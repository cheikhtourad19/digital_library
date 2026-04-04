import 'package:flutter/material.dart';

import '../../core/utils/toast_types.dart';
import '../../ui/components/toasts/app_toast.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();

  factory ToastService() {
    return _instance;
  }

  ToastService._internal();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show a success toast notification
  static void showSuccess(String message, {Duration? duration}) {
    _showToast(
      message: message,
      type: ToastType.success,
      duration: duration ?? ToastType.success.duration,
    );
  }

  /// Show an error toast notification
  static void showError(String message, {Duration? duration}) {
    _showToast(
      message: message,
      type: ToastType.error,
      duration: duration ?? ToastType.error.duration,
    );
  }

  /// Show an info toast notification
  static void showInfo(String message, {Duration? duration}) {
    _showToast(
      message: message,
      type: ToastType.info,
      duration: duration ?? ToastType.info.duration,
    );
  }

  /// Show a warning toast notification
  static void showWarning(String message, {Duration? duration}) {
    _showToast(
      message: message,
      type: ToastType.warning,
      duration: duration ?? ToastType.warning.duration,
    );
  }

  /// Generic method to show toast with custom type
  static void _showToast({
    required String message,
    required ToastType type,
    required Duration duration,
  }) {
    final context = scaffoldMessengerKey.currentState?.context;
    if (context == null) {
      // Fallback if scaffold messenger not available
      print('Toast: $message (Type: $type)');
      return;
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: AppToast(message: message, type: type, duration: duration),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Clear all active toasts
  static void dismissAll() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
  }
}
