import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/verifyuser.dart';
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

  void allertEmailVerification(BuildContext context) {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      title: 'Użytkownik niezweryfikowany',
      desc: 'Kliknij w aby przesłać E-mail do weryfikacji konta',
      buttons: [
        DialogButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            await verifyUser();
            Navigator.pushNamed(context, '/home');
          },
          color: Theme.of(context).primaryColorDark,
        ),
      ],
    ).show();
  }

  void allertAppointmentCreated(BuildContext context) {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      title: 'Udało się',
      desc: 'Pomyślnie umówiono wizytę',
      buttons: [
        DialogButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/home');
          },
          color: Theme.of(context).primaryColorDark,
        ),
      ],
    ).show();
  }

  void allertNotEnoughTime(BuildContext context) {
    Alert(
      context: context,
      style: const AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      title: 'Nie udało się',
      desc: 'Wybrano slot z niewystarczającą ilością czasu',
      buttons: [
        DialogButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/appointments');
          },
          color: Theme.of(context).primaryColorDark,
        ),
      ],
    ).show();
  }
}
