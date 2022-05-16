import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import '../helpers/appointments.dart';
import '../helpers/appointmentsapi.dart';
import '../helpers/temporarystorage.dart';

var slots = 0;

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  String now = '';
  String choosenDate = '';
  @override
  void initState() {
    super.initState();
    now = DateFormat("dd-MM-yyyy").format(DateTime.now());
    choosenDate = now;
  }

  @override
  void dispose() {
    super.dispose();
    TemporaryStorage.date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  }

  final minTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    // TemporaryStorage.date = choosenDate;
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
            flex: 3,
            child: Text(
              'Maksymalnie trzy miesiące do przodu:',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 15)),
              Expanded(
                flex: 1,
                child: Text(
                  choosenDate,
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
                      maxTime: minTime.add(
                        const Duration(days: 90),
                      ),
                      onChanged: (date) {}, onConfirm: (date) {
                    setState(() {
                      choosenDate = DateFormat('yyyy-MM-dd').format(date);
                      print(choosenDate);
                      TemporaryStorage.date = choosenDate;
                      // choosenDate = now;
                      print(TemporaryStorage.date);
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
                future: AppointmentsApi.getAppointments(context, choosenDate),
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
        // print(TemporaryStorage.serviceAverageDuration);
        // print((TemporaryStorage.serviceAverageDuration / 15).round());
        final appointment = appointments[index];
        print(slots);
        if (!appointment.occupied &&
            !appointment.reserved &&
            !appointment.holiday &&
            !appointment.sunday) {
          // print(int.parse(DateFormat("yyyy-MM-ddTHH:mm:ss")
          //         .parse(appointment.endTime, true)
          //         .toLocal()
          //         .toString()
          //         .substring(11, 16)
          //         .split(':')
          //         .join()) -
          //     int.parse(DateFormat("yyyy-MM-ddTHH:mm:ss")
          //         .parse(appointment.startTime, true)
          //         .toLocal()
          //         .toString()
          //         .substring(11, 16)
          //         .split(':')
          //         .join()));
          if (slots < (TemporaryStorage.serviceAverageDuration / 15)) {
            slots++;
            return ListTile(
              leading: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                DateFormat("yyyy-MM-ddTHH:mm:ss")
                        .parse(appointment.startTime, true)
                        .toLocal()
                        .toString()
                        .substring(11, 16) +
                    ' - ' +
                    DateFormat("yyyy-MM-ddTHH:mm:ss")
                        .parse(appointment.endTime, true)
                        .toLocal()
                        .toString()
                        .substring(11, 16),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onTap: () {
                TemporaryStorage.appointmentID = appointment.id;
                TemporaryStorage.startHour = DateFormat("yyyy-MM-ddTHH:mm:ss")
                    .parse(appointment.startTime, true)
                    .toLocal()
                    .toString()
                    .substring(11, 16);
                Navigator.pushNamed(context, '/confirmAppointment');
              },
            );
          } else {
            slots = 0;
            return const ListTile(
              leading: Icon(
                Icons.free_cancellation,
                // color: Theme.of(context).primaryColorDark,
                color: Colors.red,
              ),
              title: Text(
                'Zajęte',
                style: TextStyle(
                    // color: Theme.of(context).primaryColorDark,
                    color: Colors.red),
              ),
            );
          }
        } else if (appointment.reserved) {
          slots = 0;
          return ListTile(
            leading: const Icon(
              Icons.miscellaneous_services,
              // color: Theme.of(context).primaryColor,
              color: Colors.red,
            ),
            title: Text(
              appointment.reservedReason
                  ? 'Zarezerwowane: ${appointment.reservedReason}'
                  : 'Zarezerwowane',
              style: const TextStyle(
                  // color: Theme.of(context).primaryColor,
                  color: Colors.red),
            ),
          );
        } else if (appointment.holiday) {
          slots = 0;
          return ListTile(
            leading: Icon(
              Icons.free_cancellation,
              color: Theme.of(context).primaryColorDark,
            ),
            title: Text(
              appointment.holidayName,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          );
        } else if (appointment.sunday) {
          slots = 0;
          return ListTile(
            leading: Icon(
              Icons.free_cancellation,
              color: Theme.of(context).primaryColorDark,
            ),
            title: Text(
              'Niedziela',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          );
        } else if (appointment.occupied) {
          return const ListTile(
            leading: Icon(
              Icons.free_cancellation,
              // color: Theme.of(context).primaryColorDark,
              color: Colors.red,
            ),
            title: Text(
              'Zajęte',
              style: TextStyle(
                  // color: Theme.of(context).primaryColorDark,
                  color: Colors.red),
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
