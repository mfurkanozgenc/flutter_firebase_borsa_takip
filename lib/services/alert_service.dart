import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AlertService {
  void openModal(
      BuildContext context,
      VoidCallback onCancel,
      VoidCallback onOk,
      DialogType dialogType,
      String title,
      String desc,
      String btnButtonText,
      String btnOkText) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.topSlide,
      showCloseIcon: false,
      title: title,
      desc: desc,
      btnCancelText: btnButtonText,
      btnOkText: btnOkText,
      btnCancelOnPress: onCancel,
      btnOkOnPress: onOk,
    ).show();
  }

  static void showToast(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, textAlign: TextAlign.center),
    ));
  }
}
