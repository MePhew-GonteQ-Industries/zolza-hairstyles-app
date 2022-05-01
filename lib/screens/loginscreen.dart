import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:hairdressing_salon_app/helpers/usersecurestorage.dart';
import 'package:hairdressing_salon_app/screens/homescreen.dart';
import 'package:hairdressing_salon_app/widgets/textfieldwidget.dart';
import 'package:http/http.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helpers/loginhelper.dart';
import '../widgets/allerts.dart';
import '../widgets/textfieldwidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool checkForEmptyTextField() {
    String email, password;
    email = emailController.text;
    password = passwordController.text;
    if (email == '' || password == '') {
      Allerts().allert(context, 'Nie tak szybko...',
          'Te pola nie mogą być puste', 'OK', false, false, false);
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
          style: TextStyle(
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
          primary: Theme.of(context).primaryColorDark,
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          if (checkForEmptyTextField()) {
            Response response =
                await loginUser(emailController.text, passwordController.text);
            if (response.statusCode == 200) {
              final parsedJson = jsonDecode(response.body);
              await UserSecureStorage.setRefreshToken(
                  parsedJson['refresh_token']);
              TemporaryStorage.accessToken = parsedJson['access_token'];
              Response getInfo =
                  await getInfoRequest(TemporaryStorage.accessToken);
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
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false);
            } else if (response.statusCode == 500) {
              Allerts().allert(
                  context,
                  'Błąd połączenia',
                  'Nie udało się nawiązać połączenia z serwerem',
                  'OK',
                  false,
                  false,
                  false);
            } else if (response.statusCode == 404) {
              Allerts().allert(context, 'Podano błędne dane logowania',
                  'Spróbuj jeszcze raz', 'OK', false, false, false);
            } else if (response.statusCode == 408) {
              Allerts().allert(context, 'Błąd połączenia z serwerem',
                  'Spróbuj ponownie za chwile', 'OK', false, false, false);
            } else {
              Allerts().allert(
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
        child: const Text(
          'Zaloguj się',
          style: TextStyle(
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
          primary: color,
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () {},
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
        Navigator.pushNamed(context, '/registration');
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Nie posiadasz konta? ',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Zarejestruj się',
              style: TextStyle(
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
      backgroundColor: Theme.of(context).backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
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
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFieldWidget().textField(context, emailController,
                          'E-mail', Icons.email, false),
                      const SizedBox(height: 25),
                      TextFieldWidget().textField(context, passwordController,
                          'Hasło', Icons.lock, true),
                      const SizedBox(height: 5),
                      buildForgotPassword(),
                      const SizedBox(height: 25),
                      buildLoginBtn(),
                      const SizedBox(height: 20),
                      buildSignUpBtn(),
                      const SizedBox(height: 30),
                      buildOuterLoginButton(
                        text: 'Zaloguj przez Facebook',
                        icon: 'assets/images/facebook.svg',
                        color: const Color(0xFF246bce),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      buildOuterLoginButton(
                        text: 'Zaloguj przez Google',
                        icon: 'assets/images/google.svg',
                        color: Colors.white,
                        textColor: Colors.black,
                      ),
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
