import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:hairdressing_salon_app/widgets/drawer.dart';
import '../helpers/services_api.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      drawer: DrawerWidget().drawer(context),
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
                // print(snapshot.error);
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
                TemporaryStorage.service = service.name;
                TemporaryStorage.serviceID = service.id;
                TemporaryStorage.serviceAverageDuration = service.averageTime;
                TemporaryStorage.requiredSlots = service.requiredSlots;
                // print(TemporaryStorage.requiredSlots);
                // print(service.id);
                // print(service.name);
                // print(TemporaryStorage.serviceAverageDuration);
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
