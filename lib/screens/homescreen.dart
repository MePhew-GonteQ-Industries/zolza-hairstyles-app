import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:hairdressing_salon_app/widgets/drawerwidget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  List fetchedAppointments = [];
  bool connected = false;

  @override
  void initState() {
    super.initState();
    checkForInternetConnection();
    fetchAppointments();
  }

  fetchAppointments() async {
    var response = await http.get(
        Uri.parse(TemporaryStorage.apiUrl + '/appointments/mine'),
        headers: {
          'Authorization': 'Bearer ${TemporaryStorage.accessToken}',
          'Content-Type': 'application/json',
        });
    // print(response.statusCode);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && body != '[]') {
      setState(() {
        fetchedAppointments = body;
        // print(fetchedAppointments);
        // print(fetchedAppointments.length);
      });
    } else {
      setState(() {
        fetchedAppointments = [];
      });
    }
  }

  Widget getBody() {
    if (fetchedAppointments.isEmpty) {
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
    } else {
      return Column(
        children: [
          ListTile(
            title: Text(
              'Nadchodzące wizyty',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                physics: const BouncingScrollPhysics(),
                itemCount: fetchedAppointments.length,
                itemBuilder: (context, index) {
                  return getTile(fetchedAppointments[index]);
                }),
          )
        ],
      );
    }
  }

  Widget getTile(index) {
    var service = index['service']['name'];
    var date = index['start_slot']['start_time'];
    var archival = index['archival'];
    if (!archival) {
      return ListTile(
        title: Text(
          service,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        subtitle: Text(
          DateFormat("yyyy-MM-ddTHH:mm:ss")
              .parse(date, true)
              .toLocal()
              .toString()
              .substring(0, 16),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    } else {
      throw Exception();
    }
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
    return Scaffold(
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
      body: Align(
        alignment: Alignment.center,
        child: getBody(),
      ),
    );
  }
}
