import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:http/http.dart';
import '../helpers/login.dart';
import '../helpers/service_data.dart';
import '../helpers/services_api.dart';
import '../widgets/alerts.dart';
import '../widgets/stateful_drawer.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  ServicesState createState() => ServicesState();
}

class ServicesState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  regainAccessTokenFunction() async {
    final refreshToken = UserSecureStorage.getRefreshToken();
    // final regainFunction =
    //     regainAccessToken();
    Response regainAccessToken = await sendRefreshToken(refreshToken);

    if (regainAccessToken.statusCode == 200) {
      final regainFunction = jsonDecode(regainAccessToken.body);
      UserSecureStorage.setRefreshToken(
        regainFunction['refresh_token'],
      );
      UserData.accessToken = regainFunction['access_token'];
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/services',
        (route) => false,
      );
    } else {
      if (!mounted) return;
      Alerts().alertSessionExpired(context);
    }
  }

  buildServicesItem({
    required String text,
    required IconData icon,
  }) {
    Color color = Theme.of(context).primaryColor;
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: GoogleFonts.poppins(
            color: color,
          ),
        ),
        onTap: () {},
      ),
    );
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
      body: FutureBuilder<List<Service>>(
        future: ServicesApi.getServices(context),
        builder: (context, snapshot) {
          final services = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            default:
              if (snapshot.hasError) {
                if (snapshot.error == 401) {
                  regainAccessTokenFunction();
                }
                return Center(
                  child: Text(
                    'Wystąpił błąd przy pobieraniu danych. Spróbuj ponownie później.',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                    ),
                  ),
                );
              } else {
                return buildServices(services!);
              }
          }
        },
      ),
    );
  }
}

Widget buildServices(List<Service> services) => ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        if (service.available) {
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
                service.name,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              subtitle: Text(
                'Czas trwania: ${service.averageTime} minut | Cena: ${service.minPrice}zł-${service.maxPrice}zł',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // isThreeLine: true,
              onTap: () {
                ServiceData.name = service.name;
                ServiceData.id = service.id;
                ServiceData.averageDuration = service.averageTime;
                ServiceData.requiredSlots = service.requiredSlots;
                Navigator.pushNamed(context, '/appointments');
              },
            ),
          );
        } else {
          return Center(
            child: Text(
              'Brak dostępnych usług',
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
      },
    );
