import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/constants/globals.dart';
import 'package:hairdressing_salon_app/helpers/create_appointment.dart';
import 'package:hairdressing_salon_app/helpers/service_data.dart';
import 'package:hairdressing_salon_app/widgets/alerts.dart';
import 'package:hairdressing_salon_app/widgets/user_not_verified_widget.dart';
import 'package:http/http.dart';
import '../helpers/appointment_data.dart';
import '../helpers/login.dart';
import '../helpers/logout.dart';
import '../helpers/user_data.dart';
import '../helpers/user_secure_storage.dart';

class ConfirmAppointment extends StatefulWidget {
  const ConfirmAppointment({Key? key}) : super(key: key);

  @override
  ConfirmAppointmentState createState() => ConfirmAppointmentState();
}

class ConfirmAppointmentState extends State<ConfirmAppointment> {
  createAppointmentFunction() async {
    Response response = await createAppointment();
    // print(response.statusCode);
    // print(response.body);
    if (response.statusCode == 400) {
      if (!mounted) return;
      Alerts().alertNotEnoughTime(context);
    } else if (response.statusCode == 201) {
      GlobalState.drawerSelectedItem = 1;
      if (!mounted) return;
      Alerts().alertAppointmentCreated(context);
    } else if (response.statusCode == 403) {
      if (!mounted) return;
      Alerts().alertEmailVerification(context);
      if (!mounted) return;
    } else if (response.statusCode == 401) {
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
        createAppointmentFunction();
      } else {
        await logOutUser();
        UserSecureStorage.setRefreshToken('null');
        UserData.accessToken = 'null';
        if (!mounted) return;
        Alerts().alertSessionExpired(context);
      }
    } else if (response.statusCode == 201) {
      if (!mounted) return;
      Alerts().alertAppointmentCreated(context);
    } else {
      if (!mounted) return;
      Alerts().alert(
        context,
        'Błąd połączenia z serwerem',
        'Spróbuj ponownie później.',
        'OK',
        false,
        false,
        false,
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
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        title: Text(
          'Potwierdź wizytę',
          style: GoogleFonts.poppins(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 24,
          ),
        ),
      ),
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
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      title: Text(
                        'Umówioną wizytę może anulować tylko administrator!'
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 24,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Data:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      subtitle: Text(
                        AppointmentData.date,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Godzina:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      subtitle: Text(
                        AppointmentData.startHour,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.design_services_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Usługa:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      subtitle: Text(
                        ServiceData.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            createAppointmentFunction();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColorDark,
                            shadowColor: const Color(0xCC007AF3),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Potwierdź wizytę',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
