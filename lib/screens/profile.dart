import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/logout.dart';
import 'package:hairdressing_salon_app/helpers/update_user_details.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/widgets/stateful_drawer.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../helpers/verify_user.dart';
import '../widgets/alerts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  bool valueChanged = false;
  bool isEnabledName = true;
  bool isEnabledSurname = true;
  late FocusNode nameFocusNode;
  late FocusNode surnameFocusNode;

  @override
  void initState() {
    super.initState();
    nameController.text = UserData.name;
    surnameController.text = UserData.surname;
    isEnabledName = true;
    isEnabledSurname = true;
    nameFocusNode = FocusNode();
    surnameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    surnameFocusNode.dispose();
    super.dispose();
  }

  updateUserDetailsFunction() async {
    String name = nameController.text;
    String surname = surnameController.text;
    if (name == '') {
      name = UserData.name;
    }
    if (surname == '') {
      surname = UserData.surname;
    }
    Response response = await updateUserDetails(
      name,
      surname,
      chosenValue,
    );
    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 403 &&
        responseBody['detail'] ==
            'Additional authentication required; Authenticate using https://zolza-hairstyles.pl/api/auth/enter-sudo-mode') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Podaj hasło',
                        hintStyle: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text(
                        "Zapisz zmiany",
                        style: GoogleFonts.poppins(),
                      ),
                      onPressed: () async {
                        if (passwordController.text == '') {
                          Alerts().alert(
                            context,
                            'Nie tak szybko...',
                            'Te pola nie mogą być puste',
                            'OK',
                            false,
                            false,
                            false,
                          );
                        } else {
                          Response sudo =
                              await enterSudoMode(passwordController.text);
                          if (sudo.statusCode == 200) {
                            Response response = await updateUserDetails(
                              name,
                              surname,
                              chosenValue,
                            );

                            passwordController.text = '';
                            if (response.statusCode == 200) {
                              UserData.name = name;
                              UserData.surname = surname;
                              String gender = 'Płeć';
                              switch (chosenValue) {
                                case 'Mężczyzna':
                                  gender = 'male';
                                  break;
                                case 'Kobieta':
                                  gender = 'female';
                                  break;
                                case 'Inna':
                                  gender = 'other';
                                  break;
                                default:
                                  gender = 'Płeć';
                              }
                              UserData.gender = gender;
                              passwordController.text = '';
                              setState(() {
                                valueChanged =
                                    false; // Dlaczego przycisk nie znika?
                              });
                              buildSubmitButton();
                              if (!mounted) return;
                              Alerts().alert(
                                context,
                                'Operacja przebiegła pomyślnie',
                                'Dane zostały zmienione',
                                'OK',
                                false,
                                false,
                                true,
                              );
                            }
                          } else if (response.statusCode == 500) {
                            oldPasswordController.text = '';
                            if (!mounted) return;
                            Alerts().alert(
                              context,
                              'Błąd połączenia',
                              'Nie udało się nawiązać połączenia z serwerem',
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
                          } else if (response.statusCode == 401) {
                            final refreshToken =
                                UserSecureStorage.getRefreshToken();
                            // final regainFunction =
                            //     regainAccessToken();
                            Response regainAccessToken =
                                await sendRefreshToken(refreshToken);

                            if (regainAccessToken.statusCode == 200) {
                              final regainFunction =
                                  jsonDecode(regainAccessToken.body);
                              UserSecureStorage.setRefreshToken(
                                regainFunction['refresh_token'],
                              );
                              UserData.accessToken =
                                  regainFunction['access_token'];
                              if (!mounted) return;
                              Navigator.pushNamed(context, '/profile');
                            } else {
                              if (!mounted) return;
                              Alerts().alertSessionExpired(context);
                            }
                          } else {
                            oldPasswordController.text = '';
                            if (!mounted) return;
                            Alerts().alert(
                              context,
                              'Podano błędne dane',
                              'Spróbuj jeszcze raz',
                              'OK',
                              false,
                              false,
                              false,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (response.statusCode == 200) {
      UserData.name = name;
      UserData.surname = surname;
      String gender = 'Płeć';
      switch (chosenValue) {
        case 'Mężczyzna':
          gender = 'male';
          break;
        case 'Kobieta':
          gender = 'female';
          break;
        case 'Inna':
          gender = 'other';
          break;
        default:
          gender = 'Płeć';
      }
      UserData.gender = gender;
      // valueChanged = false;
      setState(() {
        valueChanged = false; // Dlaczego przycisk nie znika?
      });
      buildSubmitButton(); // Dlaczego przycisk nie znika?
      if (!mounted) return;
      Alerts().alert(
        context,
        'Operacja przebiegła pomyślnie',
        'Dane zostały zmienione',
        'OK',
        false,
        false,
        false,
      );
    } else if (response.statusCode == 500) {
      if (!mounted) return;
      Alerts().alert(
        context,
        'Błąd połączenia',
        'Nie udało się nawiązać połączenia z serwerem',
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
    } else if (response.statusCode == 401) {
      final refreshToken = await UserSecureStorage.getRefreshToken();
      // final regainFunction =
      //     regainAccessToken();
      Response regainAccessToken = await sendRefreshToken(refreshToken);

      if (regainAccessToken.statusCode == 200) {
        final regainFunction = jsonDecode(regainAccessToken.body);
        UserSecureStorage.setRefreshToken(
          regainFunction['refresh_token'],
        );
        UserData.accessToken = regainFunction['access_token'];
        updateUserDetailsFunction();
      } else {
        await logOutUser();
        UserSecureStorage.setRefreshToken('null');
        UserData.accessToken = 'null';
        if (!mounted) return;
        Alerts().alertSessionExpired(context);
      }
    } else {
      if (!mounted) return;
      Alerts().alert(
        context,
        'Podano błędne dane',
        'Spróbuj jeszcze raz',
        'OK',
        false,
        false,
        false,
      );
    }
  }

  String chosenValue = UserData.gender;

  List genderItem = [
    'Płeć',
    'Kobieta',
    'Mężczyzna',
    'Inna',
  ];
  buildDropDown() {
    switch (chosenValue) {
      case 'male':
        chosenValue = 'Mężczyzna';
        break;
      case 'female':
        chosenValue = 'Kobieta';
        break;
      case 'other':
        chosenValue = 'Inna';
        break;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).backgroundColor,
      ),
      child: DropdownButton(
          alignment: Alignment.center,
          style: GoogleFonts.poppins(
            color: Theme.of(context).primaryColor,
          ),
          hint: const Text('Wybierz swoją płeć'),
          value: chosenValue,
          onChanged: (value) {
            setState(() {
              chosenValue = value as String;
              String testValue;
              switch (chosenValue) {
                case 'Mężczyzna':
                  testValue = 'male';
                  break;
                case 'Kobieta':
                  testValue = 'female';
                  break;
                case 'Płeć':
                  testValue = 'placeholder';
                  break;
                default:
                  testValue = 'other';
                  break;
              }
              if (chosenValue == UserData.gender ||
                  testValue == 'placeholder') {
                valueChanged = false;
              } else {
                valueChanged = true;
              }
              buildSubmitButton();
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

  buildSubmitButton() {
    if (valueChanged) {
      switch (chosenValue) {
        case 'male':
          chosenValue = 'Mężczyzna';
          break;
        case 'female':
          chosenValue = 'Kobieta';
          break;
        case 'other':
          chosenValue = 'Inna';
          break;
      }
      return Padding(
        padding: const EdgeInsets.only(
          left: 60,
          right: 60,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              primary: Theme.of(context).primaryColorDark,
              shadowColor: const Color(0xCC007AF3),
            ),
            onPressed: () async {
              if (chosenValue == 'Płeć') {
                Alerts().alert(
                  context,
                  'Nie tak szybko...',
                  'Proszę wybrać płeć',
                  'OK',
                  false,
                  false,
                  false,
                );
              } else {
                updateUserDetailsFunction();
              }
            },
            child: Text(
              'Zapisz zmiany',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(
        width: double.infinity,
      );
    }
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
          'Profil użytkownika',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
      drawer: const CustomDrawerWidget(),
      body: ListView(
        children: [
          ListTile(
            title: Center(
              child: Text(
                '${UserData.name} ${UserData.surname}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.email,
              // color: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'E-mail',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            subtitle: Text(
              UserData.email,
              style: GoogleFonts.poppins(),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lock,
              // color: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'Hasło',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            subtitle: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: '********',
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              obscureText: true,
              controller: passwordController,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                setState(
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).backgroundColor,
                          content: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: oldPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Stare hasło',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Nowe hasło',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: rePasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Powtórz nowe hasło',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: Text(
                                      "Zapisz zmiany",
                                      style: GoogleFonts.poppins(),
                                    ),
                                    onPressed: () async {
                                      if (oldPasswordController.text == '' ||
                                          passwordController.text == '' ||
                                          rePasswordController.text == '') {
                                        Alerts().alert(
                                            context,
                                            'Nie tak szybko...',
                                            'Te pola nie mogą być puste',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                      } else if (passwordController.text !=
                                          rePasswordController.text) {
                                        Alerts().alert(
                                            context,
                                            'Nie tak szybko...',
                                            'Podane hasła muszą się zgadzać',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                      } else {
                                        Response response =
                                            await changeUserPassword(
                                                oldPasswordController.text,
                                                passwordController.text);
                                        if (response.statusCode == 200) {
                                          if (!mounted) return;
                                          Navigator.of(context).pop();
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
                                        } else if (response.statusCode == 409) {
                                          if (!mounted) return;
                                          Alerts().alert(
                                              context,
                                              'Podano błędne dane',
                                              'Zmienione hasło nie może być takie samo jak jedno z pięciu ostatnich',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 408) {
                                          if (!mounted) return;
                                          Alerts().alert(
                                              context,
                                              'Błąd połączenia z serwerem',
                                              'Spróbuj ponownie za chwile',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 401) {
                                          final refreshToken = UserSecureStorage
                                              .getRefreshToken();
                                          // final regainFunction =
                                          //     regainAccessToken();
                                          Response regainAccessToken =
                                              await sendRefreshToken(
                                                  refreshToken);

                                          if (regainAccessToken.statusCode ==
                                              200) {
                                            final regainFunction = jsonDecode(
                                                regainAccessToken.body);
                                            UserSecureStorage.setRefreshToken(
                                              regainFunction['refresh_token'],
                                            );
                                            UserData.accessToken =
                                                regainFunction['access_token'];
                                            if (!mounted) return;
                                            Navigator.pushNamed(
                                                context, '/profile');
                                          } else {
                                            if (!mounted) return;
                                            Alerts()
                                                .alertSessionExpired(context);
                                          }
                                        } else {
                                          if (!mounted) return;
                                          Alerts().alert(
                                              context,
                                              'Podano błędne dane',
                                              'Spróbuj jeszcze raz',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              // color: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'Imię',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            subtitle: TextField(
              onChanged: (text) {
                setState(() {
                  valueChanged = true;
                  buildSubmitButton();
                });
              },
              focusNode: nameFocusNode,
              enabled: isEnabledName,
              decoration: InputDecoration(
                hintText: UserData.name,
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              controller: nameController,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                setState(() {
                  isEnabledName = true;
                  nameFocusNode.requestFocus();
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              // color: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'Nazwisko',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            subtitle: TextField(
              onChanged: (text) {
                setState(() {
                  valueChanged = true;
                  buildSubmitButton();
                });
              },
              focusNode: surnameFocusNode,
              enabled: isEnabledSurname,
              decoration: InputDecoration(
                hintText: UserData.surname,
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              controller: surnameController,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                setState(() {
                  isEnabledSurname = true;
                  surnameFocusNode.requestFocus();
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              // color: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'Płeć',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            trailing: buildDropDown(),
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            title: Text(
              'Polityka prywatności',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            trailing: Icon(
              Icons.outbound_outlined,
              color: Theme.of(context).textTheme.bodyText2?.color,
            ),
            onTap: () async {
              launchUrlString('https://zolza-hairstyles.pl/privacy-policy');
            },
          ),
          if (!UserData.verified)
            ListTile(
              leading: Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Ponów weryfikację',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyText2?.color,
                ),
              ),
              subtitle: Text(
                'Kliknij aby wysłać E-mail do ponownej weryfikacji konta',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              isThreeLine: true,
              onTap: () async {
                Response verification = await verifyUser();
                if (verification.statusCode == 202) {
                  if (!mounted) return;
                  Alerts().alert(
                      context,
                      'Wysłano E-mail',
                      'Wiadomość z linkiem weryfikacyjnym została wysłana',
                      'OK',
                      false,
                      false,
                      false);
                } else if (verification.statusCode == 500) {
                  if (!mounted) return;
                  Alerts().alert(
                      context,
                      'Błąd połączenia',
                      'Nie udało się nawiązać połączenia z serwerem',
                      'OK',
                      false,
                      false,
                      false);
                } else if (verification.statusCode == 408) {
                  if (!mounted) return;
                  Alerts().alert(
                    context,
                    'Błąd połączenia',
                    'Spróbuj ponownie za chwile',
                    'OK',
                    false,
                    false,
                    false,
                  );
                } else if (verification.statusCode == 401) {
                  final refreshToken = UserSecureStorage.getRefreshToken();
                  // final regainFunction =
                  //     regainAccessToken();
                  Response regainAccessToken =
                      await sendRefreshToken(refreshToken);

                  if (regainAccessToken.statusCode == 200) {
                    final regainFunction = jsonDecode(regainAccessToken.body);
                    UserSecureStorage.setRefreshToken(
                      regainFunction['refresh_token'],
                    );
                    UserData.accessToken = regainFunction['access_token'];
                    if (!mounted) return;
                    Navigator.pushNamed(context, '/profile');
                  } else {
                    if (!mounted) return;
                    Alerts().alertSessionExpired(context);
                  }
                }
              },
            ),
          const SizedBox(
            height: 30,
          ),
          buildSubmitButton(),
        ],
      ),
    );
  }
}
