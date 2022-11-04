import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/forgot_password.dart';
import 'package:hairdressing_salon_app/widgets/text_field.dart';
import 'package:http/http.dart';
import 'package:sprintf/sprintf.dart';
import '../widgets/alerts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  int seconds = 900;
  final emailController = TextEditingController();

  bool checkForEmptyTextField() {
    String email;
    email = emailController.text;
    if (email == '') {
      Alerts().alert(context, 'Nie tak szybko...', 'Te pola nie mogą być puste',
          'OK', false, false, false);
      return false;
    } else {
      return true;
    }
  }

  tooManyRequestsAlert({required int seconds}) {
    String poprawnaForma = '';
    String retryRequest = '';
    int minutes = (seconds / 60).round();
    if (minutes == 1) {
      poprawnaForma = 'minutę';
      retryRequest =
          sprintf('Można spróbować ponownie za %i $poprawnaForma', [minutes]);
    } else if (minutes > 1 && minutes < 5) {
      poprawnaForma = 'minuty';
      retryRequest =
          sprintf('Można spróbować ponownie za %i $poprawnaForma', [minutes]);
    } else if (minutes > 4) {
      poprawnaForma = 'minut';
      retryRequest =
          sprintf('Można spróbować ponownie za %i $poprawnaForma', [minutes]);
    } else {
      poprawnaForma = 'kilka sekund';
      retryRequest = 'Można spróbować ponownie za $poprawnaForma';
    }
    Alerts().alert(context, 'Wiadomość została już wysłana', retryRequest, 'OK',
        false, true, false);
  }

  buildForgotPasswordBtn() {
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
          final ConnectivityResult result =
              await Connectivity().checkConnectivity();
          if (!(result == ConnectivityResult.none)) {
            if (checkForEmptyTextField()) {
              Response response =
                  await forgotPassword(emailController.text.trim());
              if (response.statusCode == 202) {
                if (!mounted) return;
                Alerts().alert(
                    context,
                    'Wysłano E-mail',
                    'Otwórz wiadomość i wykonaj instrukcję aby zresetować hasło',
                    'OK',
                    false,
                    true,
                    false);
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
              } else if (response.statusCode == 429) {
                var parsedJson = response.headers;
                seconds = int.parse(parsedJson['retry-after']!);
                tooManyRequestsAlert(seconds: seconds);
              } else if (response.statusCode == 408) {
                if (!mounted) return;
                Alerts().alert(context, 'Błąd połączenia z serwerem',
                    'Spróbuj ponownie za chwile', 'OK', false, false, false);
              } else {
                if (!mounted) return;
                Alerts().alert(context, 'Podano błędny adres E-mail',
                    'Spróbuj jeszcze raz', 'OK', false, false, false);
                throw Exception('Podano błędny adres E-mail');
              }
            }
          } else {
            if (!mounted) return;
            Alerts().alert(
              context,
              'Brak połączenia z internetem',
              'Podłącz się do internetu i spróbuj ponownie',
              'OK',
              false,
              false,
              false,
            );
          }
        },
        child: Text(
          'Zresetuj hasło',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Nie pamiętam hasła',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
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
                        'Aby zresetować hasło podaj swój E-mail',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          color: Theme.of(context).primaryColor,
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
                      const SizedBox(height: 40),
                      buildForgotPasswordBtn()
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
