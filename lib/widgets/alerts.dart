// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/verify_user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../screens/check_for_logged_in_user.dart';

class Alerts {
  void alert(BuildContext context, String title, String desc, String confirm,
      bool isLoop, bool isLoginRedirect, bool isPoppedSecondTime) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        descStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            if (isLoop) {
              loginLoop(context);
            } else if (isLoginRedirect) {
              // Navigator.pushNamed(context, '/login');
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            } else if (isPoppedSecondTime) {
              Navigator.pop(context);
            }
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            confirm,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  void alertEmailVerification(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        descStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: 'Użytkownik niezweryfikowany',
      desc: 'Kliknij w aby przesłać E-mail do weryfikacji konta',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            await verifyUser();
            Navigator.pushNamed(context, '/home');
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'OK',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  void alertAppointmentCreated(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        descStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: 'Udało się',
      desc: 'Pomyślnie umówiono wizytę',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'OK',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  void alertNotEnoughTime(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: 'Nie udało się',
      desc: 'Wybrano slot z niewystarczającą ilością czasu',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            // Navigator.pushNamedAndRemoveUntil(
            //     context, '/home', (route) => false);
            Navigator.pop(context);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'OK',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  void alertHomeScreenRedirect(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: 'Wystąpił błąd',
      desc: 'Spróbuj ponownie później.',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'OK',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  void alertSessionExpired(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: 'Sesja wygasła',
      desc: 'Zaloguj się aby korzystać z aplikacji.',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            GlobalState.drawerSelectedItem = 0;
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'OK',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  static void alertSaturday(BuildContext context) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        titleStyle: GoogleFonts.poppins(
          color: Colors.black,
        ),
      ),
      title: 'Sobotnie wizyty',
      desc:
          'Aby umówić się na wizytę w sobotę skontaktuj się przez wiadomość prywatną.',
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'Zrezygnuj',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
        DialogButton(
          onPressed: () async {
            launchUrlString('http://m.me/110103241392161');
            Navigator.pop(context);
          },
          color: Theme.of(context).primaryColorDark,
          child: Text(
            'Wiadomość',
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }
}
