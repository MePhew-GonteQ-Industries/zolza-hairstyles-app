import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/widgets/user_not_verified_widget.dart';
import 'package:http/http.dart' as http;
import '../helpers/service_data.dart';
import '../widgets/stateful_drawer.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  ServicesState createState() => ServicesState();
}

class ServicesState extends State<ServicesScreen> {
  late List sercvicesList;
  bool isDataFetchedServicesScreen = false;
  @override
  void initState() {
    super.initState();
    fetchServicesData();
    isDataFetchedServicesScreen = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchServicesData() async {
    var response = await http.get(
      Uri.parse('$apiUrl/services'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var body = jsonDecode(
      utf8.decode(response.bodyBytes),
    );
    if (response.statusCode == 200 && body != '[]') {
      setState(() {
        sercvicesList = body;
        isDataFetchedServicesScreen = true;
      });
    } else {
      setState(() {
        sercvicesList = [];
        isDataFetchedServicesScreen = false;
        retryFetchingServices();
      });
    }
  }

  retryFetchingServices() {
    Future.delayed(
      const Duration(seconds: 5),
    );
    fetchServicesData();
  }

  Widget getServicesBody() {
    if (isDataFetchedServicesScreen) {
      if (sercvicesList.isEmpty) {
        return Column(
          children: [
            // if (!UserData.verified) const UserNotVerified(),
            const SizedBox(
              height: 30,
            ),
            Card(
              elevation: 2,
              color: Theme.of(context).backgroundColor,
              margin: const EdgeInsets.all(8),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0x44FFFFFF),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Wystąpił problem przy pobieraniu danych. Spróbuj ponownie później.',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: sercvicesList.length,
          itemBuilder: (context, index) {
            final service = sercvicesList[index];
            final duration = service['average_time_minutes'].toString();
            final minPrice = service['min_price'].toString();
            final maxPrice = service['max_price'].toString();
            return Card(
              color: Theme.of(context).backgroundColor,
              elevation: 6,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0x44FFFFFF),
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(
                  Icons.design_services_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  service['name'],
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                subtitle: Text(
                  "Czas trwania: $duration minut | Cena: ${minPrice}zł-${maxPrice}zł",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // isThreeLine: true,
                onTap: () {
                  ServiceData.name = service['name'];
                  ServiceData.id = service['id'];
                  ServiceData.averageDuration = service['average_time_minutes'];
                  ServiceData.requiredSlots = service['required_slots'];
                  Navigator.pushNamed(context, '/appointments');
                },
              ),
            );
          },
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
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
          'Wybierz usługę',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
      drawer: const CustomDrawerWidget(),
      body: Column(
        children: [
          if (!UserData.verified)
            const Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: UserNotVerified(),
            ),
          Flexible(
            flex: 5,
            child: Center(
              child: getServicesBody(),
            ),
          ),
        ],
      ),
    );
  }
}
