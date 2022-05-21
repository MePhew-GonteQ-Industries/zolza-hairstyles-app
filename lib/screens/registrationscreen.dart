import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hairdressing_salon_app/widgets/textfieldwidget.dart';
import 'package:http/http.dart';
import '../helpers/signuphelper.dart';
import '../widgets/allerts.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String choosenValue = '';
  List genderItem = ['Płeć', 'Kobieta', 'Mężczyzna', 'Inna'];
  @override
  void initState() {
    super.initState();
    choosenValue = genderItem[0];
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final surNameController = TextEditingController();
  final rePasswordController = TextEditingController();

  bool checkForEmptyTextField() {
    String email, password, name, surename, repassword;
    email = emailController.text;
    password = passwordController.text;
    name = nameController.text;
    repassword = rePasswordController.text;
    surename = surNameController.text;
    if (email == '' ||
        password == '' ||
        name == '' ||
        surename == '' ||
        repassword == '') {
      Allerts().allert(context, 'Nie tak szybko...',
          'Te pola nie mogą być puste', 'OK', false, false, false);
      return false;
    } else if (password != repassword) {
      Allerts().allert(context, 'Nie tak szybko...',
          'Podane hasłą muszą się zgadzać', 'OK', false, false, false);
      return false;
    } else if (choosenValue == 'Płeć') {
      Allerts().allert(context, 'Nie tak szybko...', 'Proszę wybrać płeć', 'OK',
          false, false, false);
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
          padding: const EdgeInsets.all(13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          primary: Theme.of(context).primaryColorDark,
          shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          if (checkForEmptyTextField()) {
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
              nameController.text,
              surNameController.text,
              emailController.text,
              passwordController.text,
              choosenValue,
              mode,
            );
            if (response.statusCode == 201) {
              Navigator.pushNamed(context, '/login');
              Allerts().allert(
                  context,
                  'Zarejestrowano pomyślnie',
                  'Zaloguj się aby korzystać z aplikacji',
                  'OK',
                  false,
                  false,
                  false);
            } else if (response.statusCode == 404 ||
                response.statusCode == 500) {
              Allerts().allert(
                  context,
                  'Błąd połączenia',
                  'Nie udało się nawiązać połączenia z serwerem',
                  'OK',
                  false,
                  false,
                  false);
            } else if (response.statusCode == 408) {
              Allerts().allert(
                  context,
                  'Błąd połączenia',
                  'Nie udało się nawiązać połączenia z serwerem',
                  'Spróbuj ponownie',
                  true,
                  false,
                  false);
            } else {
              // print(response.statusCode);
              Allerts().allert(context, 'Podano błędne dane rejestracji',
                  'Spróbuj jeszcze raz', 'OK', false, false, false);
            }
          }
        },
        child: const Text(
          'Zarejestruj się',
          style: TextStyle(
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
        Navigator.pushNamed(context, '/login');
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Masz już konto? ',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "Zaloguj się",
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

  buildDropDown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).backgroundColor,
      ),
      child: DropdownButton(
          alignment: Alignment.center,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
          ),
          hint: const Text('Wybierz swoją rolę'),
          value: choosenValue,
          onChanged: (value) {
            setState(() {
              choosenValue = value as String;
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
                  color: Theme.of(context).backgroundColor,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 90,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zarejestruj się',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      buildDropDown(),
                      const SizedBox(height: 20),
                      TextFieldWidget().textField(
                          context, nameController, 'Imię', Icons.person, false),
                      const SizedBox(height: 20),
                      TextFieldWidget().textField(context, surNameController,
                          'Nazwisko', Icons.person, false),
                      const SizedBox(height: 20),
                      TextFieldWidget().textField(context, emailController,
                          'E-mail', Icons.email, false),
                      const SizedBox(height: 20),
                      TextFieldWidget().textField(context, passwordController,
                          'Hasło', Icons.lock, true),
                      const SizedBox(height: 20),
                      TextFieldWidget().textField(context, rePasswordController,
                          'Powtórz hasło', Icons.lock, true),
                      const SizedBox(height: 40),
                      buildSignUpBtn(),
                      const SizedBox(height: 20),
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
