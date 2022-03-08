import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../screens/checkforloggeduser.dart';

class Allerts {
  void allert(BuildContext context, String title, String desc, String confirm,
      bool isLoop, bool isLoginRedirect, bool isPoppedSecondTime) {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            confirm,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            if (isLoop) {
              loginLoop(context);
            } else if (isLoginRedirect) {
              Navigator.pushNamed(context, '/login');
            } else if (isPoppedSecondTime) {
              Navigator.pop(context);
            }
          },
          color: Theme.of(context).primaryColorDark,
        ),
      ],
    ).show();
  }
}
