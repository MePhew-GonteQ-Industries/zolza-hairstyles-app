import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/create_appointment.dart';
import 'package:hairdressing_salon_app/helpers/temporary_storage.dart';
import 'package:hairdressing_salon_app/widgets/alerts.dart';
import 'package:http/http.dart';

class ConfirmAppointment extends StatefulWidget {
  const ConfirmAppointment({Key? key}) : super(key: key);

  @override
  ConfirmAppointmentState createState() => ConfirmAppointmentState();
}

class ConfirmAppointmentState extends State<ConfirmAppointment> {
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
          'Potwierdź wizytę',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
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
                  TemporaryStorage.date,
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
                  TemporaryStorage.startHour,
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
                  TemporaryStorage.service,
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
                    onPressed: () async {
                      Response response = await createAppointment();
                      // print(response.statusCode);
                      // print(response.body);
                      if (response.statusCode == 400) {
                        Alerts().alertNotEnoughTime(context);
                      } else if (response.statusCode == 201) {
                        Alerts().alertAppointmentCreated(context);
                      } else if (response.statusCode == 403) {
                        Alerts().alertEmailVerification(context);
                      } else {
                        Alerts().alertHomeScreenRedirect(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColorDark,
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
    );
  }
}
