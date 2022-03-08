import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairdressing_salon_app/widgets/drawerwidget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<ContactScreen> {
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
          'Kontakt',
          style: TextStyle(
            color: Theme.of(context).backgroundColor,
          ),
        ),
      ),
      drawer: DrawerWidget().drawer(context),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Telefon',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch('tel:+48 730 601 830');
              },
            ), //phone
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
              onTap: () async {
                launch('mailto:zolza.hairstyles@gmail.com');
              },
            ), //email
            ListTile(
              leading: SvgPicture.asset(
                'assets/images/messenger.svg',
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Messenger',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch('https://messenger.com/t/110103241392161');
              },
            ), //messenger
            ListTile(
              leading: Icon(
                Icons.facebook,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Facebook',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch('https://facebook.com/Zołza-Hairstyles-110103241392161');
              },
            ), //facebook
            ListTile(
              leading: SvgPicture.asset(
                'assets/images/instagram.svg',
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Instagram',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch('https://instagram.com/zolza_hairstyles/');
              },
            ), //instagram
            ListTile(
              leading: Icon(
                Icons.web,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Strona internetowa',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch('https://mephew.ddns.net');
              },
            ), //webpage
            ListTile(
              leading: Icon(
                Icons.map,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Mapa',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () async {
                launch(
                    'https://google.pl/maps/place/Laskowa+916,+34-602+Laskowa/@49.7638655,20.4511658,17.64z/data=!4m5!3m4!1s0x47161c246be6b0d9:0x3b5fa2297e3fc12e!8m2!3d49.7638646!4d20.4522641');
              },
            ), //maps
          ],
        ),
      ),
    );
  }
}
