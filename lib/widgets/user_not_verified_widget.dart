import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import '../helpers/login.dart';
import '../helpers/user_data.dart';
import '../helpers/user_secure_storage.dart';
import '../helpers/verify_user.dart';
import 'alerts.dart';

class UserNotVerified extends StatefulWidget {
  const UserNotVerified({Key? key}) : super(key: key);

  @override
  State<UserNotVerified> createState() => _UserNotVerifiedState();
}

class _UserNotVerifiedState extends State<UserNotVerified> {
  Color color = const Color.fromRGBO(255, 180, 0, 1);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Response verification = await verifyUser();
        if (verification.statusCode == 202) {
          if (!mounted) return;
          Alerts().alert(
              context,
              'Wysłano E-mail',
              'Wiadomość z linkiem weryfikacyjnym została wysłana',
              'OK',
              false,
              false,
              false);
        } else if (verification.statusCode == 500) {
          if (!mounted) return;
          Alerts().alert(
              context,
              'Błąd połączenia',
              'Nie udało się nawiązać połączenia z serwerem',
              'OK',
              false,
              false,
              false);
        } else if (verification.statusCode == 408) {
          if (!mounted) return;
          Alerts().alert(
            context,
            'Błąd połączenia',
            'Spróbuj ponownie za chwile',
            'OK',
            false,
            false,
            false,
          );
        } else if (verification.statusCode == 401) {
          final refreshToken = UserSecureStorage.getRefreshToken();
          // final regainFunction =
          //     regainAccessToken();
          Response regainAccessToken = await sendRefreshToken(refreshToken);

          if (regainAccessToken.statusCode == 200) {
            final regainFunction = jsonDecode(regainAccessToken.body);
            UserSecureStorage.setRefreshToken(
              regainFunction['refresh_token'],
            );
            UserData.accessToken = regainFunction['access_token'];
            if (!mounted) return;
            Navigator.pushNamed(context, '/profile');
          } else {
            if (!mounted) return;
            Alerts().alertSessionExpired(context);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: 20,
        ),
        child: Container(
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(20),
            color: Color.fromRGBO(255, 180, 0, 0.2),
          ),
          // height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: color,
                    ),
                  ),
                  Text(
                    'Nie zweryfikowane konto',
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              Text(
                'Kliknij aby wysłać email z linkiem do weryfikacji.',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
