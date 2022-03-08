import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/services.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:hairdressing_salon_app/widgets/drawerwidget.dart';
import '../helpers/servicesapi.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<ServicesScreen> {
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
          style: TextStyle(color: color),
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
        title: Text('Wybierz usługę',
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            )),
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
                return const Center(
                  child: Text(
                      'Wystąpił błąd przy pobieraniu danych. Spróbuj ponownie później.'),
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
          return ListTile(
            leading: Icon(
              Icons.design_services_rounded,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              service.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Text(
              'Czas trwania: ' +
                  service.averageTime.toString() +
                  ' minut | Cena: ' +
                  service.maxPrice.toString() +
                  'zł',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              TemporaryStorage.service = service.name;
              Navigator.pushNamed(context, '/appointments');
            },
          );
        } else {
          return Center(
            child: Text(
              'Brak dostępnych usług',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
        }
      },
    );
