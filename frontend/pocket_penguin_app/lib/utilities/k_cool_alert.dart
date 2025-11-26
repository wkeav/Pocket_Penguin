import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

Future kCoolAlert({
  required String message,
  required BuildContext context,
  required CoolAlertType alert,
  bool barrierDismissible = true,
  String confirmBtnText = 'Ok',
}) {
  return CoolAlert.show(
    backgroundColor: AppColor.primaryColor,
    confirmBtnColor: AppColor.secondaryColor,
    context: context,
    type: alert,
    text: message,
    barrierDismissible: barrierDismissible,
    confirmBtnText: confirmBtnText,
  );
}
