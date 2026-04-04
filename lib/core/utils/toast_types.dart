import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

extension ToastTypeExtension on ToastType {
  IconData get icon {
    switch (this) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
      case ToastType.warning:
        return Icons.warning;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.info:
        return Colors.blue.shade600;
      case ToastType.warning:
        return Colors.orange.shade600;
    }
  }

  Color get textColor => Colors.white;

  Duration get duration => const Duration(seconds: 3);
}
