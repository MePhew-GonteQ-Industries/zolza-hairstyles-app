import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/FCM/get_fcm_token.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/external_sign_in/google_sign_in.dart';
import 'package:hairdressing_salon_app/screens/home.dart';
import 'package:hairdressing_salon_app/widgets/text_field.dart';
import 'package:http/http.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helpers/login.dart';
import '../helpers/user_data.dart';
import '../widgets/alerts.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool checkForEmptyTextField() {
    String email, password;
    email = emailController.text;
    password = passwordController.text;
    if (email == '' || password == '') {
      Alerts().alert(context, 'Nie tak szybko...', 'Te pola nie mogą być puste',
          'OK', false, false, false);
      return false;
    } else {
      return true;
    }
  }

  buildForgotPassword() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/forgotPassword'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(right: 0),
        ),
        child: Text(
          'Nie pamiętasz hasła?',
          style: GoogleFonts.poppins(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildLoginBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          padding: const EdgeInsets.all(13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // ba: Theme.of(context).primaryColorDark,
          // foregroundColor: Theme.of(context).primaryColorDark,
          backgroundColor: Theme.of(context).primaryColorDark,
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          if (checkForEmptyTextField()) {
            Response response = await loginUser(
                emailController.text.trim(), passwordController.text.trim());
            if (response.statusCode == 200) {
              final parsedJson = jsonDecode(response.body);
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
              // final fcmToken = await FirebaseMessaging.instance.getToken();
              // print(fcmToken);
              await GetFcmToken().setUpToken();
              await UserSecureStorage.setIsLoggedIn('true');
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false);
            } else if (response.statusCode == 500) {
              if (!mounted) return;
              Alerts().alert(
                  context,
                  'Błąd połączenia',
                  'Nie udało się nawiązać połączenia z serwerem',
                  'OK',
                  false,
                  false,
                  false);
            } else if (response.statusCode == 404) {
              if (!mounted) return;
              Alerts().alert(
                context,
                'Podano błędne dane logowania',
                'Spróbuj jeszcze raz',
                'OK',
                false,
                false,
                false,
              );
            } else if (response.statusCode == 408) {
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
                  'Błąd połączenia',
                  'Nie udało się nawiązać połączenia z serwerem',
                  'Spróbuj ponownie',
                  true,
                  false,
                  false);
            }
          }
        },
        child: Text(
          'Zaloguj się',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildOuterLoginButton({
    required String text,
    required String icon,
    required Color color,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          padding: const EdgeInsets.only(
            right: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          // primary: color,
          backgroundColor: color,
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          // await GoogleSignIn.signIn();
          signInGoogle();
        },
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SvgPicture.asset(icon),
            ),
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSignUpBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/registration', (route) => false);
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Nie posiadasz konta? ',
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Zarejestruj się',
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColorDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 120,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaloguj się',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFieldWidget().textField(
                        context,
                        emailController,
                        'E-mail',
                        Icons.email,
                        false,
                        TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),
                      TextFieldWidget().textField(
                        context,
                        passwordController,
                        'Hasło',
                        Icons.lock,
                        true,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 5),
                      buildForgotPassword(),
                      const SizedBox(height: 25),
                      buildLoginBtn(),
                      const SizedBox(height: 20),
                      buildSignUpBtn(),
                      // const SizedBox(height: 30),
                      // buildOuterLoginButton(
                      //   text: 'Zaloguj przez Facebook',
                      //   icon: 'assets/images/facebook.svg',
                      //   color: const Color(0xFF246bce),
                      //   textColor: Colors.white,
                      // ),
                      // const SizedBox(height: 20),
                      // buildOuterLoginButton(
                      //   text: 'Zaloguj przez Google',
                      //   icon: 'assets/images/google.svg',
                      //   color: Colors.red,
                      //   textColor: Colors.black,
                      // ),
                      // const SizedBox(height: 20),
                      // buildOuterLoginButton(
                      //   text: 'Zaloguj przez Apple',
                      //   icon: 'assets/images/apple.svg',
                      //   color: Colors.white,
                      //   textColor: Colors.black,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
