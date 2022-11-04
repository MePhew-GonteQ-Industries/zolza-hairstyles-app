import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/delete_account.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/widgets/alerts.dart';
import 'package:hairdressing_salon_app/widgets/text_field.dart';
import 'package:http/http.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();

  bool checkForEmptyTextField() {
    String password, rePassword;
    password = passwordController.text;
    rePassword = rePasswordController.text;
    if (password == '' || rePassword == '') {
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
    } else {
      return true;
    }
  }

  bool checkForMatchingPassword() {
    String password, rePassword;
    password = passwordController.text;
    rePassword = rePasswordController.text;
    if (password != rePassword) {
      Alerts().alert(
        context,
        'Nie tak szybko',
        'Podane hasła się nie zgadzają',
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
          // primary: Theme.of(context).primaryColorDark,
          primary: const Color.fromRGBO(255, 76, 81, 0.3),
          // shadowColor: const Color(0xCC007AF3),
        ),
        onPressed: () async {
          if (checkForEmptyTextField()) {
            if (checkForMatchingPassword()) {
              Response response = await deleteUserAccount(
                  passwordController.text.trim(), UserData.accessToken);
              if (response.statusCode == 200) {
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } else if (response.statusCode == 422) {
                if (!mounted) return;
                Alerts().alert(context, 'Niepowodzenie',
                    'Podano nieprawidłowe dane', 'Okej', false, false, false);
              }
            }
          }
        },
        child: Text(
          'Usuń konto',
          style: GoogleFonts.poppins(
            // color: Colors.white,
            color: const Color.fromRGBO(255, 76, 81, 1),
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
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Usuń konto',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
      // drawer: const CustomDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
            ),
            Text(
              'Akcja jest nieodwracalna!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            TextFieldWidget().textField(
              context,
              passwordController,
              'Hasło',
              Icons.lock,
              true,
              TextInputType.text,
            ),
            const SizedBox(
              height: 25,
            ),
            TextFieldWidget().textField(
              context,
              rePasswordController,
              'Powtórz Hasło',
              Icons.lock,
              true,
              TextInputType.text,
            ),
            const SizedBox(
              height: 45,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: buildLoginBtn(),
            ),
          ],
        ),
      ),
    );
  }
}
