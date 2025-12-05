import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum CoolAlertType {
  success,
  error,
  warning,
  info,
}

Future<void> kCoolAlert({
  required String message,
  required BuildContext context,
  required CoolAlertType alert,
  bool barrierDismissible = true,
  String confirmBtnText = 'Ok',
}) {
  IconData icon;
  Color color;

  switch (alert) {
    case CoolAlertType.success:
      icon = Icons.check_circle;
      color = Colors.green;
      break;
    case CoolAlertType.error:
      icon = Icons.error;
      color = Colors.red;
      break;
    case CoolAlertType.warning:
      icon = Icons.warning;
      color = Colors.orange;
      break;
    case CoolAlertType.info:
      icon = Icons.info;
      color = Colors.blue;
      break;
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColor.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColor.secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmBtnText),
          ),
        ],
      );
    },
  );
}
