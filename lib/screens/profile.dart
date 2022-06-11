import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:hairdressing_salon_app/helpers/update_user_details.dart';
import 'package:http/http.dart';
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
  bool onChangedValue = false;
  bool isEnabledName = false;
  bool isEnabledSurname = false;
  late FocusNode nameFocusNode;
  late FocusNode surNameFocusNode;

  @override
  void initState() {
    super.initState();
    nameController.text = TemporaryStorage.name;
    surnameController.text = TemporaryStorage.surName;
    isEnabledName = false;
    isEnabledSurname = false;
    nameFocusNode = FocusNode();
    surNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    surNameFocusNode.dispose();
    super.dispose();
  }

  String chosenValue = TemporaryStorage.gender;

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
          hint: const Text('Wybierz swoją rolę'),
          value: chosenValue,
          onChanged: (value) {
            setState(() {
              chosenValue = value as String;
              onChangedValue = true;
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
    if (onChangedValue) {
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
                String name = nameController.text;
                String surName = surnameController.text;
                if (name == '') {
                  name = TemporaryStorage.name;
                }
                if (surName == '') {
                  surName = TemporaryStorage.surName;
                }
                Response response =
                    await updateUserDetails(name, surName, chosenValue);
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
                                          false);
                                    } else {
                                      Response sudo = await enterSudoMode(
                                          passwordController.text);
                                      if (sudo.statusCode == 200) {
                                        Response response =
                                            await updateUserDetails(
                                                name, surName, chosenValue);

                                        passwordController.text = '';
                                        if (response.statusCode == 200) {
                                          TemporaryStorage.name = name;
                                          TemporaryStorage.surName = surName;
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
                                          TemporaryStorage.gender = gender;
                                          passwordController.text = '';
                                          Alerts().alert(
                                              context,
                                              'Operacja przebiegła pomyślnie',
                                              'Dane zostały zmienione',
                                              'OK',
                                              false,
                                              false,
                                              true);
                                        }
                                      } else if (response.statusCode == 500) {
                                        Alerts().alert(
                                            context,
                                            'Błąd połączenia',
                                            'Nie udało się nawiązać połączenia z serwerem',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                        oldPasswordController.text = '';
                                      } else if (response.statusCode == 408) {
                                        Alerts().alert(
                                            context,
                                            'Błąd połączenia z serwerem',
                                            'Spróbuj ponownie za chwile',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                      } else {
                                        Alerts().alert(
                                            context,
                                            'Podano błędne dane',
                                            'Spróbuj jeszcze raz',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                        oldPasswordController.text = '';
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
                  TemporaryStorage.name = name;
                  TemporaryStorage.surName = surName;
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
                  TemporaryStorage.gender = gender;
                  Alerts().alert(context, 'Operacja przebiegła pomyślnie',
                      'Dane zostały zmienione', 'OK', false, false, false);
                } else if (response.statusCode == 500) {
                  Alerts().alert(
                      context,
                      'Błąd połączenia',
                      'Nie udało się nawiązać połączenia z serwerem',
                      'OK',
                      false,
                      false,
                      false);
                } else if (response.statusCode == 408) {
                  Alerts().alert(context, 'Błąd połączenia z serwerem',
                      'Spróbuj ponownie za chwile', 'OK', false, false, false);
                } else {
                  Alerts().alert(context, 'Podano błędne dane',
                      'Spróbuj jeszcze raz', 'OK', false, false, false);
                }
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
      body: ListView(
        children: [
          ListTile(
            title: Center(
              child: Text(
                '${TemporaryStorage.name} ${TemporaryStorage.surName}',
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
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'E-mail',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyText2?.color,
              ),
            ),
            subtitle: Text(
              TemporaryStorage.email,
              style: GoogleFonts.poppins(),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lock,
              color: Theme.of(context).primaryColor,
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
                                          Navigator.of(context).pop();
                                        } else if (response.statusCode == 500) {
                                          Alerts().alert(
                                              context,
                                              'Błąd połączenia',
                                              'Nie udało się nawiązać połączenia z serwerem',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 409) {
                                          Alerts().alert(
                                              context,
                                              'Podano błędne dane',
                                              'Zmienione hasło nie może być takie samo jak jedno z pięciu ostatnich',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 408) {
                                          Alerts().alert(
                                              context,
                                              'Błąd połączenia z serwerem',
                                              'Spróbuj ponownie za chwile',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else {
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
              color: Theme.of(context).primaryColor,
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
                  onChangedValue = true;
                  buildSubmitButton();
                });
              },
              focusNode: nameFocusNode,
              enabled: isEnabledName,
              decoration: InputDecoration(
                hintText: TemporaryStorage.name,
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
              color: Theme.of(context).primaryColor,
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
                  onChangedValue = true;
                  buildSubmitButton();
                });
              },
              focusNode: surNameFocusNode,
              enabled: isEnabledSurname,
              decoration: InputDecoration(
                hintText: TemporaryStorage.surName,
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
                  surNameFocusNode.requestFocus();
                  isEnabledSurname = true;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
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
                Alerts().alert(
                    context,
                    'Wysłano E-mail',
                    'Wiadomość z linkiem weryfikacyjnym została wysłana',
                    'OK',
                    false,
                    false,
                    false);
              } else if (verification.statusCode == 500) {
                Alerts().alert(
                    context,
                    'Błąd połączenia',
                    'Nie udało się nawiązać połączenia z serwerem',
                    'OK',
                    false,
                    false,
                    false);
              } else if (verification.statusCode == 408) {
                Alerts().alert(context, 'Błąd połączenia',
                    'Spróbuj ponownie za chwile', 'OK', false, false, false);
              }
              // print(TemporaryStorage.email);
              // print(verification.statusCode);
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
