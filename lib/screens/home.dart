import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/widgets/user_not_verified_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../helpers/login.dart';
import '../helpers/logout.dart';
import '../helpers/user_data.dart';
import '../widgets/alerts.dart';
import '../widgets/stateful_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  late List fetchedAppointments;
  bool connected = false;
  bool isDataFetchedHomeScreen = false;

  @override
  void initState() {
    super.initState();
    checkForInternetConnection();
    fetchAppointments();
    isDataFetchedHomeScreen = false;
  }

  retryFetchingAppointmentsHomeScreen() {
    Future.delayed(
      const Duration(seconds: 5),
    );
    fetchAppointments();
  }

  fetchAppointments() async {
    var response = await http.get(
      Uri.parse('$apiUrl/appointments/mine'),
      headers: {
        'Authorization': 'Bearer ${UserData.accessToken}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      // print('regaining token');
      final refreshToken = await UserSecureStorage.getRefreshToken();
      // final regainFunction =
      //     regainAccessToken();
      http.Response regainAccessToken = await sendRefreshToken(refreshToken);

      if (regainAccessToken.statusCode == 200) {
        // print('token regained');
        final regainFunction = jsonDecode(regainAccessToken.body);
        UserSecureStorage.setRefreshToken(
          regainFunction['refresh_token'],
        );
        UserData.accessToken = regainFunction['access_token'];
        if (!mounted) return;
        fetchAppointments();
      } else {
        await logOutUser();
        UserSecureStorage.setRefreshToken('null');
        UserData.accessToken = 'null';
        if (!mounted) return;
        Alerts().alertSessionExpired(context);
      }
    }
    // print(response.statusCode);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && body != '[]') {
      setState(() {
        fetchedAppointments = body;
        isDataFetchedHomeScreen = true;
        // print(fetchedAppointments);
        // print(fetchedAppointments.length);
      });
    } else {
      setState(() {
        fetchedAppointments = [];
        isDataFetchedHomeScreen = false;
        retryFetchingAppointmentsHomeScreen();
      });
    }
  }

  Widget getBody() {
    if (isDataFetchedHomeScreen) {
      if (fetchedAppointments.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!UserData.verified)
              const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: UserNotVerified(),
              ),
            Flexible(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Wygląda na to,\nże nie masz umówionej wizyty,\nkliknij przycisk aby to zrobić',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                        fontSize: 22,
                        // fontWeight: FontWeight.bold,
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
                      child: Text(
                        'Umów wizytę',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/services');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            if (!UserData.verified) const UserNotVerified(),
            ListTile(
              title: Text(
                'Nadchodzące wizyty',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
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
    } else {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }
  }

  Widget getTile(index) {
    var service = index['service']['name'];
    var date = index['start_slot']['start_time'];
    var archival = index['archival'];
    if (!archival) {
      return Card(
        color: Theme.of(context).backgroundColor,
        elevation: 3,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Color(0x44FFFFFF),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(4),
        child: ListTile(
          title: Center(
            child: Text(
              service,
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          subtitle: Center(
            child: Text(
              DateFormat("yyyy-MM-ddTHH:mm:ss")
                  .parse(date, true)
                  .toLocal()
                  .toString()
                  .substring(0, 16),
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
              ),
            ),
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
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
      ),
      // drawer: DrawerWidget().drawer(context),
      drawer: const CustomDrawerWidget(),
      body: Align(
        alignment: Alignment.center,
        child: getBody(),
      ),
    );
  }
}
