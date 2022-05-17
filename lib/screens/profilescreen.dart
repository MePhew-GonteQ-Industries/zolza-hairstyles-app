import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:hairdressing_salon_app/helpers/updateuserdetailshelper.dart';
import 'package:http/http.dart';
import '../helpers/verifyuser.dart';
import '../widgets/allerts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();
  final nameController = TextEditingController();
  final surNameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  bool onChangedValue = false;
  bool isEnabledName = false;
  bool isEnabledSurName = false;
  late FocusNode nameFocusNode;
  late FocusNode surNameFocusNode;

  @override
  void initState() {
    super.initState();
    nameController.text = TemporaryStorage.name;
    surNameController.text = TemporaryStorage.surName;
    isEnabledName = false;
    isEnabledSurName = false;
    nameFocusNode = FocusNode();
    surNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    surNameFocusNode.dispose();
    super.dispose();
  }

  String choosenValue = TemporaryStorage.gender;

  List genderItem = [
    'Płeć',
    'Kobieta',
    'Mężczyzna',
    'Inna',
  ];
  buildDropDown() {
    switch (choosenValue) {
      case 'male':
        choosenValue = 'Mężczyzna';
        break;
      case 'female':
        choosenValue = 'Kobieta';
        break;
      case 'other':
        choosenValue = 'Inna';
        break;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).backgroundColor,
      ),
      child: DropdownButton(
          alignment: Alignment.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
          hint: const Text('Wybierz swoją rolę'),
          value: choosenValue,
          onChanged: (value) {
            setState(() {
              choosenValue = value as String;
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
      switch (choosenValue) {
        case 'male':
          choosenValue = 'Mężczyzna';
          break;
        case 'female':
          choosenValue = 'Kobieta';
          break;
        case 'other':
          choosenValue = 'Inna';
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
              if (choosenValue == 'Płeć') {
                Allerts().allert(context, 'Nie tak szybko...',
                    'Proszę wybrać płeć', 'OK', false, false, false);
              } else {
                String name = nameController.text;
                String surName = surNameController.text;
                if (name == '') {
                  name = TemporaryStorage.name;
                }
                if (surName == '') {
                  surName = TemporaryStorage.surName;
                }
                Response response =
                    await updateUserDetails(name, surName, choosenValue);
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
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  child: const Text("Zapisz zmiany"),
                                  onPressed: () async {
                                    if (passwordController.text == '') {
                                      Allerts().allert(
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
                                                name, surName, choosenValue);

                                        passwordController.text = '';
                                        if (response.statusCode == 200) {
                                          TemporaryStorage.name = name;
                                          TemporaryStorage.surName = surName;
                                          String gender = 'Płeć';
                                          switch (choosenValue) {
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
                                          Allerts().allert(
                                              context,
                                              'Operacja przebiegła pomyślnie',
                                              'Dane zostały zmienione',
                                              'OK',
                                              false,
                                              false,
                                              true);
                                        }
                                      } else if (response.statusCode == 500) {
                                        Allerts().allert(
                                            context,
                                            'Błąd połączenia',
                                            'Nie udało się nawiązać połączenia z serwerem',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                        oldPasswordController.text = '';
                                      } else if (response.statusCode == 408) {
                                        Allerts().allert(
                                            context,
                                            'Błąd połączenia z serwerem',
                                            'Spróbuj ponownie za chwile',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                      } else {
                                        Allerts().allert(
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
                  switch (choosenValue) {
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
                  Allerts().allert(context, 'Operacja przebiegła pomyślnie',
                      'Dane zostały zmienione', 'OK', false, false, false);
                } else if (response.statusCode == 500) {
                  Allerts().allert(
                      context,
                      'Błąd połączenia',
                      'Nie udało się nawiązać połączenia z serwerem',
                      'OK',
                      false,
                      false,
                      false);
                } else if (response.statusCode == 408) {
                  Allerts().allert(context, 'Błąd połączenia z serwerem',
                      'Spróbuj ponownie za chwile', 'OK', false, false, false);
                } else {
                  Allerts().allert(context, 'Podano błędne dane',
                      'Spróbuj jeszcze raz', 'OK', false, false, false);
                }
              }
            },
            child: const Text(
              'Zapisz zmiany',
              style: TextStyle(
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
          style: TextStyle(color: Theme.of(context).backgroundColor),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Center(
              child: Text(
                TemporaryStorage.name + ' ' + TemporaryStorage.surName,
                style: TextStyle(
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
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            subtitle: Text(
              TemporaryStorage.email,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lock,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Hasło',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            subtitle: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: '********',
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              obscureText: true,
              controller: passwordController,
              style: TextStyle(
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
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: TextStyle(
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
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: TextStyle(
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
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: const Text("Zapisz zmiany"),
                                    onPressed: () async {
                                      if (oldPasswordController.text == '' ||
                                          passwordController.text == '' ||
                                          rePasswordController.text == '') {
                                        Allerts().allert(
                                            context,
                                            'Nie tak szybko...',
                                            'Te pola nie mogą być puste',
                                            'OK',
                                            false,
                                            false,
                                            false);
                                      } else if (passwordController.text !=
                                          rePasswordController.text) {
                                        Allerts().allert(
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
                                          Allerts().allert(
                                              context,
                                              'Błąd połączenia',
                                              'Nie udało się nawiązać połączenia z serwerem',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 409) {
                                          Allerts().allert(
                                              context,
                                              'Podano błędne dane',
                                              'Zmienione hasło nie może być takie samo jak jedno z pięciu ostatnich',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else if (response.statusCode == 408) {
                                          Allerts().allert(
                                              context,
                                              'Błąd połączenia z serwerem',
                                              'Spróbuj ponownie za chwile',
                                              'OK',
                                              false,
                                              false,
                                              false);
                                        } else {
                                          Allerts().allert(
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
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              controller: nameController,
              style: TextStyle(
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
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
              enabled: isEnabledSurName,
              decoration: InputDecoration(
                hintText: TemporaryStorage.surName,
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              controller: surNameController,
              style: TextStyle(
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
                  isEnabledSurName = true;
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
              style: TextStyle(
                color: Theme.of(context).primaryColor,
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
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            subtitle: Text(
              'Kliknij aby wysłać E-mail do ponownej weryfikacji konta',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            isThreeLine: true,
            onTap: () async {
              Response verification = await verifyUser();
              if (verification.statusCode == 202) {
                Allerts().allert(
                    context,
                    'Wysłano E-mail',
                    'Wiadmość z linkiem weryfikacyjnym została wysłana',
                    'OK',
                    false,
                    false,
                    false);
              } else if (verification.statusCode == 500) {
                Allerts().allert(
                    context,
                    'Błąd połączenia',
                    'Nie udało się nawiązać połączenia z serwerem',
                    'OK',
                    false,
                    false,
                    false);
              } else if (verification.statusCode == 408) {
                Allerts().allert(context, 'Błąd połączenia',
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
