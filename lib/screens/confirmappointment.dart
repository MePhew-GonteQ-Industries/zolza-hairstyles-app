import 'package:flutter/material.dart';
import 'package:hairdressing_salon_app/helpers/createappointmenthelper.dart';
import 'package:hairdressing_salon_app/helpers/temporarystorage.dart';
import 'package:http/http.dart';

class ConfirmAppointment extends StatefulWidget {
  const ConfirmAppointment({Key? key}) : super(key: key);

  @override
  _ConfirmAppointment createState() => _ConfirmAppointment();
}

class _ConfirmAppointment extends State<ConfirmAppointment> {
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
          style: TextStyle(
            color: Theme.of(context).backgroundColor,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              TemporaryStorage.date + ' ' + TemporaryStorage.startHour,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 24),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  primary: Theme.of(context).primaryColorDark,
                  shadowColor: const Color(0xCC007aF3),
                ),
                child: Text(
                  'Potwierdź wizyę',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () async {
                  Response response = await createAppointment();
                  print(response.statusCode);
                  print(response.body);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
