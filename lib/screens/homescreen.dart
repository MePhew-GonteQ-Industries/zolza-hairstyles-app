import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/widgets/drawerwidget.dart';
import 'package:http/http.dart' as http;
import '../helpers/temporarystorage.dart';

Future<Appointment> fetchAppointment() async {
  final response = await http.get(
    Uri.parse('https://zolza-hairstyles.pl/api/appointments/mine'),
    headers: {
      'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
      'Content-Type': 'application/json',
    },
  );
  final body = jsonDecode(response.body);
  print((body['appointments']));
  if (response.statusCode == 200 && body['appointments'] == '') {
    print('pusta tablica');
    return Appointment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Brak umówionych wizyt');
  }
}

class Appointment {
  final int userId;
  final int id;
  final String title;
  final String body;

  Appointment({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  bool connected = false;
  late Future<Appointment> futureAppointment;

  @override
  void initState() {
    super.initState();
    checkForInternetConnection();
    futureAppointment = fetchAppointment();
  }

  void checkForInternetConnection() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        connected = false;
      });
    } else {
      setState(() {
        connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // MaterialApp(
        //   theme: ThemeData(
        //     bottomAppBarColor: lightPrimaryColor,
        //   ),
        //   darkTheme: ThemeData(
        //     bottomAppBarColor: lightBackgroundColor,
        //   ),
        //   debugShowCheckedModeBanner: false,
        //   home:
        Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Zołza Hairstyles',
          style: TextStyle(color: Theme.of(context).backgroundColor),
        ),
      ),
      drawer: DrawerWidget().drawer(context),
      body: Center(
        child: FutureBuilder<Appointment>(
          future: futureAppointment,
          builder: (context, snapshot) {
            if (connected) {
              if (snapshot.hasData) {
                return Text(
                  'Title: \n${snapshot.data!.title}\n\n Body: \n${snapshot.data!.body}\n\n userId: \n${snapshot.data!.userId}\n\n id: \n${snapshot.data!.id}',
                  style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Wygląda na to\nże nie masz umówionej wizyty,\nkliknij przycisk aby to zrobić',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          padding: const EdgeInsets.all(13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          primary: Theme.of(context).primaryColorDark,
                          shadowColor: const Color(0xCC007AF3),
                        ),
                        child: const Text('Umów wizytę',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        onPressed: () {
                          Navigator.pushNamed(context, '/services');
                        },
                      ),
                    ],
                  ),
                );
              }
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Text(
                        'Nie udało się załadować danych o wizytach, sprawdź swoje polączenie z internetem i spróbuj ponownie',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
