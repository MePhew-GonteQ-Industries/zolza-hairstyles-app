import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import '../helpers/logout.dart';
import '../helpers/temporary_storage.dart';
import '../helpers/user_secure_storage.dart';
import '../screens/login.dart';
import 'allerts.dart';

class DrawerWidget {
  Widget drawer(BuildContext context) {
    buildMenuItem({
      required String text,
      required IconData icon,
      required int index,
    }) {
      Color color = Theme.of(context).primaryColor;
      return ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 18,
          ),
        ),
        onTap: () => selectedItem(context, index),
      );
    }

    buildLogOutBtn() {
      Color color = Theme.of(context).primaryColor;
      return ListTile(
        leading: Icon(
          Icons.logout,
          color: color,
        ),
        title: Text(
          'Wyloguj się',
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 18,
          ),
        ),
        onTap: () async {
          final ConnectivityResult result =
              await Connectivity().checkConnectivity();
          if (result == ConnectivityResult.none) {
            Allerts().allert(
                context,
                'Błąd połączenia',
                'Sprawdź swoje połączenie z internetem i spróbuj ponownie',
                'OK',
                false,
                false,
                false);
          } else {
            Response logOut = await logOutUser();
            if (logOut.statusCode == 200) {
              UserSecureStorage.setRefreshToken('null');
              TemporaryStorage.accessToken = 'null';
              UserSecureStorage.setFCMToken('null');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false);
            } else if (logOut.statusCode == 408) {
              Allerts().allert(context, 'Błąd połączenia z serwerem',
                  'Spróbuj ponownie za chwile', 'OK', false, false, false);
            } else {
              Allerts().allert(context, 'Błąd połączenia z serwerem',
                  'Spróbuj jeszcze raz', 'OK', false, false, false);
            }
          }
        },
      );
    }

    return Drawer(
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Witaj, ${TemporaryStorage.name}',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildMenuItem(
              text: 'Strona główna',
              icon: Icons.home_outlined,
              index: 0,
            ),
            const SizedBox(height: 6),
            buildMenuItem(
              text: 'Umów wizytę',
              icon: Icons.schedule,
              index: 1,
            ),
            // const SizedBox(height: 6),
            // buildMenuItem(
            //   text: 'Usługi',
            //   icon: Icons.design_services_rounded,
            //   index: 2,
            // ),
            const SizedBox(height: 6),
            buildMenuItem(
              text: 'Kontakt',
              icon: Icons.contact_page_outlined,
              index: 3,
            ),
            Divider(
              height: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 16,
            ),
            buildLogOutBtn(),
          ],
        ),
      ),
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/services');
        break;
      // case 2:
      //   Navigator.pushNamed(context, '/services');
      //   break;
      case 3:
        Navigator.pushNamed(context, '/contact');
        break;
    }
  }
}
