import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:http/http.dart';
import '../helpers/login.dart';
import '../helpers/logout.dart';
import '../helpers/user_data.dart';
import '../helpers/user_secure_storage.dart';
import '../screens/login.dart';
import 'alerts.dart';

class CustomDrawerWidget extends StatefulWidget {
  const CustomDrawerWidget({Key? key, BuildContext? context}) : super(key: key);

  @override
  DrawerWidgetState createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<CustomDrawerWidget> {
  int activeIndex = GlobalState.drawerSelectedItem;

  // @override
  // void initState() {
  //   super.initState();
  //   activeIndex = 4;
  // }

  buildMenuItem({
    required String text,
    required IconData icon,
    required int index,
    required Color color,
  }) {
    // Color color = Theme.of(context).primaryColor;
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
          if (!mounted) return;
          Alerts().alert(
              context,
              'Błąd połączenia',
              'Sprawdź swoje połączenie z internetem i spróbuj ponownie',
              'OK',
              false,
              false,
              false);
        } else {
          Response logOut = await logOutUser();
          print(logOut.statusCode);
          print(logOut.body);
          if (logOut.statusCode == 200) {
            UserSecureStorage.setRefreshToken('null');
            UserData.accessToken = 'null';
            UserSecureStorage.setFCMToken('null');
            UserSecureStorage.setIsLoggedIn('false');
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false);
          } else if (logOut.statusCode == 408) {
            if (!mounted) return;
            Alerts().alert(
              context,
              'Błąd połączenia z serwerem',
              'Spróbuj ponownie za chwile',
              'OK',
              false,
              false,
              false,
            );
          } else if (logOut.statusCode == 401) {
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
              Response logOut = await logOutUser();
              if (logOut.statusCode == 200) {
                UserSecureStorage.setRefreshToken('null');
                UserData.accessToken = 'null';
                UserSecureStorage.setFCMToken('null');
                UserSecureStorage.setIsLoggedIn('false');
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false);
              } else if (logOut.statusCode == 408) {
                if (!mounted) return;
                Alerts().alert(
                  context,
                  'Błąd połączenia z serwerem',
                  'Spróbuj ponownie za chwile',
                  'OK',
                  false,
                  false,
                  false,
                );
              } else {
                if (!mounted) return;
                Alerts().alert(
                  context,
                  'Błąd połączenia z serwerem',
                  'Spróbuj jeszcze raz',
                  'OK',
                  false,
                  false,
                  false,
                );
              }
            } else {
              if (!mounted) return;
              Alerts().alertSessionExpired(context);
            }
          } else {
            if (!mounted) return;
            Alerts().alert(
              context,
              'Błąd połączenia z serwerem',
              'Spróbuj jeszcze raz',
              'OK',
              false,
              false,
              false,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(context) {
    return Drawer(
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
                        'Witaj, ${UserData.name}',
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
              color: 0 == activeIndex
                  ? Theme.of(context).hoverColor
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 6),
            buildMenuItem(
              text: 'Umów wizytę',
              icon: Icons.schedule,
              index: 1,
              color: 1 == activeIndex
                  ? Theme.of(context).hoverColor
                  : Theme.of(context).primaryColor,
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
              index: 2,
              color: 2 == activeIndex
                  ? Theme.of(context).hoverColor
                  : Theme.of(context).primaryColor,
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
    setState(() {
      GlobalState.drawerSelectedItem = index;
    });
    switch (index) {
      case 0:
        // Navigator.pushNamed(context, '/home');
        activeIndex = 0;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        // Navigator.pushNamed(context, '/services');
        Navigator.pushNamedAndRemoveUntil(
            context, '/services', (route) => false);
        break;
      // case 2:
      //   Navigator.pushNamed(context, '/services');
      //   break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
            context, '/contact', (route) => false);
        // Navigator.pushNamed(context, '/contact');
        break;
    }
  }
}
