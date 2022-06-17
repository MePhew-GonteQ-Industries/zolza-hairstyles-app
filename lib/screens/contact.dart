import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../widgets/stateful_drawer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  ContactState createState() => ContactState();
}

class ContactState extends State<ContactScreen> {
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
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
      drawer: const CustomDrawerWidget(),
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
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                launchUrlString('tel://+48730601830');
              },
            ), //phone
            ListTile(
              leading: Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'E-mail',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                launchUrlString('mailto:zolza.hairstyles@gmail.com');
              },
            ), //email
            ListTile(
              leading: SvgPicture.asset(
                'assets/images/messenger.svg',
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Messenger',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                // launchUrlString('https://www.messenger.com/t/110103241392161');
                // launchUrlString('fb-messenger://profile/110103241392161');
                launchUrlString('http://m.me/110103241392161');
                // launchUrlString('messenger://110103241392161');
                // await MessengerLauncher.launchMessenger('110103241392161');
              },
            ), //messenger
            ListTile(
              leading: Icon(
                Icons.facebook,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Facebook',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                // launchUrlString(
                //     'https://www.facebook.com/Zo%C5%82za-Hairstyles-110103241392161');
                launchUrlString('fb://profile/110103241392161');
              },
            ), //facebook
            ListTile(
              leading: SvgPicture.asset(
                'assets/images/instagram.svg',
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Instagram',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                // launchUrlString('https://www.instagram.com/zolza_hairstyles/');
                launchUrlString('instagram://user?username=zolza_hairstyles');
              },
            ), //instagram
            ListTile(
              leading: Icon(
                Icons.web,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Strona internetowa',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                launchUrlString('https://zolza-hairstyles.pl');
              },
            ), //webpage
            ListTile(
              leading: Icon(
                Icons.map,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Mapa',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              ),
              onTap: () async {
                // launchUrlString(
                //     'http://google.pl/maps/place/Laskowa+916,+34-602+Laskowa/@49.7638655,20.4511658,17.64z/data=!4m5!3m4!1s0x47161c246be6b0d9:0x3b5fa2297e3fc12e!8m2!3d49.7638646!4d20.4522641');
                launchUrlString('https://goo.gl/maps/CjFED1cwCwg4H8yi6');
              },
            ), //maps
          ],
        ),
      ),
    );
  }
}
