// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/screens/login.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/widgets/alerts.dart';
import 'package:http/http.dart';
import '../FCM/get_fcm_token.dart';
import 'home.dart';
import 'dart:convert';

var loading = true;

class CheckForLoggedUserScreen extends StatefulWidget {
  const CheckForLoggedUserScreen({Key? key}) : super(key: key);

  @override
  CheckForLoggedUserScreenState createState() =>
      CheckForLoggedUserScreenState();
}

class CheckForLoggedUserScreenState extends State<CheckForLoggedUserScreen> {
  @override
  void initState() {
    super.initState();
    checkForLoggedUser();
    loading = true;
    // loginLoop(context);
  }

  void checkForLoggedUser() async {
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      if (!mounted) return;
      Alerts().alert(
          context,
          'Brak połączenia',
          'Sprawdź swoje połączenie z internetem',
          'Spróbuj ponownie',
          true,
          false,
          false);
    } else {
      var refreshTokenSecureStorage = await UserSecureStorage.getRefreshToken();
      if (refreshTokenSecureStorage != null) {
        try {
          Response refreshToken =
              await sendRefreshToken(refreshTokenSecureStorage);
          if (refreshToken.statusCode == 200) {
            final parsedJson = jsonDecode(refreshToken.body);
            await UserSecureStorage.setRefreshToken(
                parsedJson['refresh_token']);
            UserData.accessToken = parsedJson['access_token'];
            Response getInfo = await getInfoRequest(UserData.accessToken);
            final parsedInfo = jsonDecode(utf8.decode(getInfo.bodyBytes));
            UserData.name = parsedInfo['name'];
            UserData.surname = parsedInfo['surname'];
            UserData.email = parsedInfo['email'];
            UserData.verified = parsedInfo['verified'];
            switch (parsedInfo['gender']) {
              case 'male':
                UserData.gender = 'Mężczyzna';
                break;
              case 'female':
                UserData.gender = 'Kobieta';
                break;
              case 'other':
                UserData.gender = 'Inna';
                break;
              default:
                UserData.gender = 'Płeć';
            }
            await GetFcmToken().setUpToken();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false);
          } else if (refreshToken.statusCode == 401) {
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              ((route) => false),
            );
          } else {
            if (!mounted) return;
            loginLoop(context);
          }
        } catch (e) {
          setState(() {
            loading = false;
          });
        }
      } else {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          ((route) => false),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              // SvgPicture.asset(
              //   'assets/images/logo_dark.svg',
              //   color: Theme.of(context).primaryColor,
              //   height: 80,
              //   width: 80,
              // ),
              const SizedBox(
                height: 80,
              ),
              Image.asset(
                'assets/images/launch_image_light.png',
                color: Theme.of(context).primaryColor,
                height: 80,
                width: 80,
              ),
              const SizedBox(
                height: 30,
              ),
              if (loading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ),
                ),
              if (!loading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 45, right: 45),
                        child: Text(
                          'Nie udało się połączyć z serwerem, spróbuj ponownie później.',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    ));
  }
}

void loginLoop(BuildContext context) async {
  var refreshTokenSecureStorage = await UserSecureStorage.getRefreshToken();
  var currentTime = DateTime.now();
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500));
    var timeout = currentTime.add(
      const Duration(milliseconds: 10000),
    );
    var now = DateTime.now();
    if (timeout.difference(now).inMilliseconds < 0) {
      Alerts().alert(
          context,
          'Błąd połączenia',
          'Nie udało się nawiązać połączenia z serwerem',
          'Spróbuj ponownie',
          true,
          false,
          false);
      break;
    }
    Response refreshToken = await sendRefreshToken(refreshTokenSecureStorage);
    if (refreshToken.statusCode == 200) {
      final parsedJson = jsonDecode(refreshToken.body);
      await UserSecureStorage.setRefreshToken(parsedJson['refresh_token']);
      UserData.accessToken = parsedJson['access_token'];
      Response getInfo = await getInfoRequest(UserData.accessToken);
      final parsedInfo = jsonDecode(utf8.decode(getInfo.bodyBytes));
      UserData.name = parsedInfo['name'];
      UserData.surname = parsedInfo['surname'];
      UserData.email = parsedInfo['email'];
      UserData.verified = parsedInfo['verified'];
      switch (parsedInfo['gender']) {
        case 'male':
          UserData.gender = 'Mężczyzna';
          break;
        case 'female':
          UserData.gender = 'Kobieta';
          break;
        case 'other':
          UserData.gender = 'Inna';
          break;
        default:
          UserData.gender = 'Płeć';
      }
      await GetFcmToken().setUpToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } else if (refreshToken.statusCode == 401) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
  }
}
