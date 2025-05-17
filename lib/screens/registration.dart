import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/widgets/text_field.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../helpers/sign_up_helper.dart';
import '../widgets/alerts.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  String chosenValue = '';
  List genderItem = ['Płeć', 'Kobieta', 'Mężczyzna', 'Inna'];
  @override
  void initState() {
    super.initState();
    chosenValue = genderItem[0];
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool agreement = false;

  bool checkForEmptyTextField() {
    String email, password, name, surname, repeatPassword;
    email = emailController.text;
    password = passwordController.text;
    name = nameController.text;
    repeatPassword = repeatPasswordController.text;
    surname = surnameController.text;
    if (email == '' ||
        password == '' ||
        name == '' ||
        surname == '' ||
        repeatPassword == '') {
      Alerts().alert(
        context,
        'Nie tak szybko...',
        'Te pola nie mogą być puste',
        'OK',
        false,
        false,
        false,
      );
      return false;
    } else if (password != repeatPassword) {
      Alerts().alert(
        context,
        'Nie tak szybko...',
        'Podane hasła muszą się zgadzać',
        'OK',
        false,
        false,
        false,
      );
      return false;
    } else if (chosenValue == 'Płeć') {
      Alerts().alert(
        context,
        'Nie tak szybko...',
        'Proszę wybrać płeć',
        'OK',
        false,
        false,
        false,
      );
      return false;
    } else {
      return true;
    }
  }

  buildSignUpBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Theme.of(context).primaryColorDark,
          padding: const EdgeInsets.all(13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          if (checkForEmptyTextField()) {
            if (agreement) {
              var brightness =
                  SchedulerBinding.instance.window.platformBrightness;
              bool isDarkMode = brightness == Brightness.dark;
              String mode = 'light';
              switch (isDarkMode) {
                case true:
                  mode = 'dark';
                  break;
                default:
                  mode = 'light';
              }
              Response response = await signUpUser(
                nameController.text.trim(),
                surnameController.text.trim(),
                emailController.text.trim(),
                passwordController.text.trim(),
                chosenValue,
                mode,
              );
              if (response.statusCode == 201) {
                if (!mounted) return;
                // Navigator.pushNamedAndRemoveUntil(
                // context, '/login', (route) => false);
                Alerts().alert(
                    context,
                    'Zarejestrowano pomyślnie',
                    'Zaloguj się aby korzystać z aplikacji',
                    'OK',
                    false,
                    true,
                    false);
              } else if (response.statusCode == 404 ||
                  response.statusCode == 500) {
                if (!mounted) return;
                Alerts().alert(
                    context,
                    'Błąd połączenia',
                    'Nie udało się nawiązać połączenia z serwerem',
                    'OK',
                    false,
                    false,
                    false);
              } else if (response.statusCode == 408) {
                if (!mounted) return;
                Alerts().alert(
                    context,
                    'Błąd połączenia',
                    'Nie udało się nawiązać połączenia z serwerem',
                    'Spróbuj ponownie',
                    true,
                    false,
                    false);
              } else {
                // print(response.statusCode);
                if (!mounted) return;
                Alerts().alert(
                  context,
                  'Podano błędne dane rejestracji',
                  'Spróbuj jeszcze raz',
                  'OK',
                  false,
                  false,
                  false,
                );
              }
            }
          } else {
            Alerts().alert(
              context,
              'Akceptacja regulaminu',
              'Aby się zarejestrować należy zaakceptować regulamin',
              'OK',
              false,
              false,
              false,
            );
          }
        },
        child: Text(
          'Zarejestruj się',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildLogInBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Masz już konto? ',
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "Zaloguj się",
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

  buildDropDown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: DropdownButton(
          alignment: Alignment.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
          ),
          hint: const Text('Wybierz swoją rolę'),
          value: chosenValue,
          onChanged: (value) {
            setState(() {
              chosenValue = value as String;
            });
          },
          items: genderItem.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
              ),
            );
          }).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    vertical: 85,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zarejestruj się',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildDropDown(),
                      const SizedBox(height: 10),
                      TextFieldWidget().textField(
                        context,
                        nameController,
                        'Imię',
                        Icons.person,
                        false,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget().textField(
                        context,
                        surnameController,
                        'Nazwisko',
                        Icons.person,
                        false,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget().textField(
                        context,
                        emailController,
                        'E-mail',
                        Icons.email,
                        false,
                        TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget().textField(
                        context,
                        passwordController,
                        'Hasło',
                        Icons.lock,
                        true,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hasło musi zawierać małą oraz dużą literę, cyfrę oraz znak specjanlny, np: #, @, !, >.',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      TextFieldWidget().textField(
                        context,
                        repeatPasswordController,
                        'Powtórz hasło',
                        Icons.lock,
                        true,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          children: <Widget>[
                            Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Theme.of(context).scaffoldBackgroundColor,
                              side: MaterialStateBorderSide.resolveWith(
                                (states) => BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              value: agreement,
                              onChanged: (bool? value) {
                                setState(() {
                                  agreement = value!;
                                });
                              },
                            ),
                            Wrap(
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Akceptuję ',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'regulamin serwisu',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrlString(
                                            'https://zolza-hairstyles.pl/terms-of-use');
                                      },
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: ' i ',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'politykę prywatności',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrlString(
                                            'https://zolza-hairstyles.pl/privacy-policy');
                                      },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildSignUpBtn(),
                      const SizedBox(height: 10),
                      buildLogInBtn(),
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
