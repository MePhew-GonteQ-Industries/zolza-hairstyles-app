import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import '../helpers/appointments.dart';
import '../helpers/appointmentsapi.dart';
import '../helpers/temporarystorage.dart';

var currentSlotFits = 0;
var requiredSlots = 0;
var hasSlots = 0;

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  String now = '';
  String chosenDate = '';
  @override
  void initState() {
    super.initState();
    now = DateFormat("dd-MM-yyyy").format(DateTime.now());
    chosenDate = now;
    currentSlotFits = 0;
    hasSlots = 0;
    requiredSlots = TemporaryStorage.requiredSlots;
  }

  @override
  void dispose() {
    super.dispose();
    TemporaryStorage.date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  }

  final minTime = DateTime.now();
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
                  chosenDate,
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
                      chosenDate = DateFormat('yyyy-MM-dd').format(date);
                      TemporaryStorage.date = chosenDate;
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
                future: AppointmentsApi.getAppointments(context, chosenDate),
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
                        print(snapshot.data);
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

Widget buildAppointments(List<Appointment> appointments) {
  if (appointments.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 2,
            color: Colors.blue,
            margin: const EdgeInsets.all(8),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Color(0x44FFFFFF),
                width: 1,
              ),
            ),
            child: const ListTile(
              leading: Icon(
                Icons.miscellaneous_services,
                color: Colors.red,
              ),
              title: Text(
                'Brak wolnych miejsc',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          )
        ],
      ),
    );
  } else {
    return areSlots(appointments);
  }
}

Widget areSlots(List<Appointment> appointments) => ListView.builder(
      // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 3,
      // ),
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        currentSlotFits = 0;
        if (index + requiredSlots <= appointments.length) {
          for (int i = index; i < (index + requiredSlots); i++) {
            final slot = appointments[i];

            if (slot.occupied) {
              break;
            }

            if (slot.reserved) {
              break;
            }

            if (slot.holiday) {
              break;
            }

            if (slot.sunday) {
              break;
            }

            if (currentSlotFits == requiredSlots) {
              break;
            }
            hasSlots++;
            currentSlotFits++;
          }
        }
        if (appointment.reserved) {
          return Card(
            elevation: 2,
            color: Theme.of(context).backgroundColor,
            margin: const EdgeInsets.all(8),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Color(0x44FFFFFF),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.miscellaneous_services,
                color: Colors.red,
              ),
              title: Text(
                appointment.reservedReason
                    ? 'Zarezerwowane: ${appointment.reservedReason}'
                    : 'Zarezerwowane',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          );
        } else if (appointment.holiday) {
          return Card(
            elevation: 2,
            color: Theme.of(context).backgroundColor,
            margin: const EdgeInsets.all(8),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x44FFFFFF),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.free_cancellation,
                color: Colors.red,
              ),
              title: Text(
                appointment.holidayName,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          );
        } else if (appointment.sunday) {
          return Card(
            elevation: 2,
            color: Theme.of(context).backgroundColor,
            margin: const EdgeInsets.all(8),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x44FFFFFF),
                width: 1,
              ),
            ),
            child: const ListTile(
              leading: Icon(
                Icons.free_cancellation,
                color: Colors.red,
              ),
              title: Text(
                'Niedziela',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          );
        } else if (appointment.occupied) {
          // return Card(
          //   elevation: 6,
          //   color: Colors.red,
          //   margin: const EdgeInsets.all(8),
          //   shape: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(25),
          //     borderSide: const BorderSide(
          //       color: Color(0x44FFFFFF),
          //       width: 1,
          //     ),
          //   ),
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.free_cancellation,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //     title: Text(
          //       'Zajęte',
          //       style: TextStyle(
          //         color: Theme.of(context).primaryColor,
          //       ),
          //     ),
          //   ),
          // );
          return const SizedBox.shrink();
        } else if (currentSlotFits == requiredSlots) {
          return Card(
            // shape: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(25),
            //   borderSide: const BorderSide(
            //     color: Color(0x44FFFFFF),
            //     width: 1,
            //   ),
            // ),
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: ListTile(
                // leading: Icon(
                //   Icons.access_time,
                //   color: Theme.of(context).primaryColor,
                // ),
                title: Center(
                  child: Text(
                    'Od: ' +
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(appointment.startTime, true)
                            .toLocal()
                            .toString()
                            .substring(11, 16),
                    // +
                    // ' - ' +
                    // DateFormat("yyyy-MM-ddTHH:mm:ss")
                    //     .parse(appointment.endTime, true)
                    //     .add(Duration(
                    //       minutes: 15 * (requiredSlots - 1),
                    //     ))
                    //     .toLocal()
                    //     .toString()
                    //     .substring(11, 16),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                subtitle: Center(
                  child: Text(
                    'Do: ' +
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(appointment.endTime, true)
                            .add(
                              Duration(
                                minutes: 30 * (requiredSlots - 1),
                              ),
                            )
                            .toLocal()
                            .toString()
                            .substring(11, 16),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
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
              ),
            ),
            elevation: 8,
            // shape: CircleBorder(
            //   side: BorderSide(
            //     width: 1,
            //     color: Color(0x44FFFFFF),
            //   ),
            // ),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x44FFFFFF),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.all(10),
          );
        } else if (appointments.isEmpty) {
          print('isempty');
          return Text('Brak wolnych miejsc');
        } else {
          // return Card(
          //   elevation: 6,
          //   color: Colors.red,
          //   margin: const EdgeInsets.all(8),
          //   shape: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(25),
          //     borderSide: const BorderSide(
          //       color: Color(0x44FFFFFF),
          //       width: 1,
          //     ),
          //   ),
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.free_cancellation,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //     title: Text(
          //       'Brak wolnych miejsc',
          //       style: TextStyle(
          //         color: Theme.of(context).primaryColor,
          //       ),
          //     ),
          //   ),
          // );
          return const SizedBox.shrink();
        }
      },
    );
