import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/screens/login.dart';
import 'package:hairdressing_salon_app/widgets/allerts.dart';
import 'package:http/http.dart';
import '../FCM/get_fcm_token.dart';
import 'home.dart';
import 'dart:convert';

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
    // loginLoop(context);
  }

  void checkForLoggedUser() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      Allerts().allert(
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
        Response refreshToken =
            await sendRefreshToken(refreshTokenSecureStorage);
        // print(refreshToken.statusCode);
        // print(refreshToken.body);
        // print(refreshToken.statusCode);
        if (refreshToken.statusCode == 200) {
          final parsedJson = jsonDecode(refreshToken.body);
          await UserSecureStorage.setRefreshToken(parsedJson['refresh_token']);
          TemporaryStorage.accessToken = parsedJson['access_token'];
          Response getInfo = await getInfoRequest(TemporaryStorage.accessToken);
          final parsedInfo = jsonDecode(utf8.decode(getInfo.bodyBytes));
          TemporaryStorage.name = parsedInfo['name'];
          TemporaryStorage.surName = parsedInfo['surname'];
          TemporaryStorage.email = parsedInfo['email'];
          switch (parsedInfo['gender']) {
            case 'male':
              TemporaryStorage.gender = 'Mężczyzna';
              break;
            case 'female':
              TemporaryStorage.gender = 'Kobieta';
              break;
            case 'other':
              TemporaryStorage.gender = 'Inna';
              break;
            default:
              TemporaryStorage.gender = 'Płeć';
          }
          await GetFcmToken().setUpToken();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false);
        } else if (refreshToken.statusCode == 401) {
          Navigator.pushNamed(context, '/login');
        } else {
          loginLoop(context);
        }
      } else {
        Navigator.pushNamed(context, '/login');
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
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
      Allerts().allert(
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
    // print(refreshToken.statusCode);
    if (refreshToken.statusCode == 200) {
      final parsedJson = jsonDecode(refreshToken.body);
      await UserSecureStorage.setRefreshToken(parsedJson['refresh_token']);
      TemporaryStorage.accessToken = parsedJson['access_token'];
      Response getInfo = await getInfoRequest(TemporaryStorage.accessToken);
      final parsedInfo = jsonDecode(utf8.decode(getInfo.bodyBytes));
      TemporaryStorage.name = parsedInfo['name'];
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