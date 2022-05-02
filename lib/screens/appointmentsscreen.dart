import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import '../helpers/appointments.dart';
import '../helpers/appointmentsapi.dart';
import '../helpers/temporarystorage.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
  }

  final minTime = DateTime.now();
  String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
  String choosenDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text('Wybierz datę',
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            )),
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 15),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Maksymalnie trzy miesiące do przodu',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 15)),
              Expanded(
                flex: 1,
                child: Text(
                  now,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: minTime,
                      maxTime: minTime.add(const Duration(days: 90)),
                      onChanged: (date) {}, onConfirm: (date) {
                    print(DateFormat('yyyy-MM-dd').format(date));
                    choosenDate = DateFormat('yyyy-MM-dd').format(date);
                    print(choosenDate);
                    TemporaryStorage.date = choosenDate;
                    print(TemporaryStorage.date);
                    setState(() {
                      // hourIsChoosen = true;
                      // buildSubmitButton();
                      now = DateFormat('dd-MM-yyyy').format(date);
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.pl);
                },
              ),
              const Padding(padding: EdgeInsets.only(right: 15)),
            ],
          ),
          Expanded(
            flex: 30,
            child: Align(
              alignment: Alignment.center,
              child: FutureBuilder<List<Appointment>>(
                future: AppointmentsApi.getAppointments(
                    context, TemporaryStorage.date),
                builder: (context, snapshot) {
                  final appointments = snapshot.data;
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Text(
                              'Wystąpił błąd przy pobieraniu danych. Spróbuj ponownie później.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              )),
                        );
                      } else {
                        return buildAppointments(appointments!);
                      }
                  }
                },
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 15)),
        ],
      ),
    );
  }
}

Widget buildAppointments(List<Appointment> appointments) => ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        if (!appointment.occupied &&
            !appointment.reserved &&
            !appointment.holiday &&
            !appointment.sunday) {
          return ListTile(
            leading: Icon(
              Icons.access_time,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              (appointment.startTime).substring(11, 16) +
                  ' - ' +
                  (appointment.endTime).substring(11, 16),
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              TemporaryStorage.appointmentID = appointment.id;
              TemporaryStorage.startHour =
                  (appointment.startTime).substring(11, 16);
              Navigator.pushNamed(context, '/confirmAppointment');
            },
          );
        } else if (appointment.reserved) {
          return ListTile(
            leading: Icon(
              Icons.miscellaneous_services,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              appointment.reservedReason,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
        } else if (appointment.holiday) {
          return ListTile(
            leading: Icon(
              Icons.holiday_village,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              appointment.holidayName,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
        } else if (appointment.sunday) {
          return ListTile(
            leading: Icon(
              Icons.free_cancellation,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Niedziela',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
        } else {
          return Text(
            'Wystąpił problem, spróbuj ponownie później',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
