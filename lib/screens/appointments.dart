import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/appointment_data.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../constants/globals.dart';
import '../helpers/appointments.dart';
import '../helpers/logout.dart';
import '../helpers/service_data.dart';
import '../widgets/alerts.dart';
import 'package:http/http.dart' as http;

var currentSlotFits = 0;
var requiredSlots = 0;
var hasSlots = 0;

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  AppointmentsState createState() => AppointmentsState();
}

class AppointmentsState extends State<AppointmentsScreen> {
  late String currentDate;
  late DateTime now;
  late String chosenDateString;
  late DateTime chosenDate;
  List appointmentsData = [];
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    currentDate = DateFormat("dd-MM-yyyy").format(now);
    chosenDate = now;
    chosenDateString = DateFormat('yyyy-MM-dd').format(chosenDate);
    currentSlotFits = 0;
    hasSlots = 0;
    requiredSlots = ServiceData.requiredSlots;
    fetchAppointmentsData();
  }

  @override
  void dispose() {
    super.dispose();
    currentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    AppointmentData.date = currentDate;
  }

  fetchAppointmentsData() async {
    var response = await http.get(
      Uri.parse('$apiUrl/appointments/slots?date=$chosenDateString'),
      headers: {
        'Authorization': 'Bearer ${UserData.accessToken}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 401) {
      regainAccessTokenFunction();
    }
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    print(body);
    if (response.statusCode == 200 && body != '[]') {
      setState(() {
        appointmentsData = body;
      });
    } else {
      appointmentsData = [];
    }
  }

  regainAccessTokenFunction() async {
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
      if (!mounted) return;
      Navigator.pop(context);
      fetchAppointmentsData();
    } else {
      await logOutUser();
      UserSecureStorage.setRefreshToken('null');
      UserData.accessToken = 'null';
      if (!mounted) return;
      Alerts().alertSessionExpired(context);
    }
  }

  Widget getAppointmentsBody() {
    if (appointmentsData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Wystąpił problem połącznia z serwerem, spróbuj ponownie później.',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22,
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: appointmentsData.length,
        itemBuilder: (context, index) {
          // return getAppointmentTile(appointmentsData[index]);
          final appointment = appointmentsData[index];
          currentSlotFits = 0;
          // print(currentSlotFits);
          if (index + requiredSlots <= appointmentsData.length) {
            for (int i = index; i < (index + requiredSlots); i++) {
              final slot = appointmentsData[i];

              if (slot['occupied']) {
                break;
              }

              if (slot['reserved']) {
                break;
              }

              if (slot['holiday']) {
                break;
              }

              if (slot['sunday']) {
                break;
              }

              if (slot['break_time']) {
                break;
              }

              if (currentSlotFits == requiredSlots) {
                break;
              }
              hasSlots++;
              currentSlotFits++;
            }
          }
          if (appointment['reserved']) {
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      appointment['reserved_reason']
                          ? "Zarezerwowane: ${appointment['reserved_reason']}"
                          : 'Zarezerwowane',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (appointment['holiday']) {
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      appointment['holiday_name'],
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (appointment['sunday']) {
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      'Niedziela',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (appointment['occupied']) {
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
              child: Center(
                child: ListTile(
                  // leading: Icon(
                  //   Icons.access_time,
                  //   color: Theme.of(context).primaryColor,
                  // ),
                  title: Center(
                    child: Text(
                      "Od: ${DateFormat('yyyy-MM-ddTHH:mm:ss').parse(appointment['start_time'], true).toLocal().toString().substring(11, 16)}",
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
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  subtitle: Center(
                    child: Text(
                      "Do: ${DateFormat('yyyy-MM-ddTHH:mm:ss').parse(appointment['end_time'], true).add(
                            Duration(
                              minutes: 30 * (requiredSlots - 1),
                            ),
                          ).toLocal().toString().substring(11, 16)}",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onTap: () {
                    AppointmentData.id = appointment['id'];
                    AppointmentData.startHour =
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(appointment['start_time'], true)
                            .toLocal()
                            .toString()
                            .substring(11, 16);
                    AppointmentData.date = chosenDateString;
                    Navigator.pushNamed(context, '/confirmAppointment');
                  },
                ),
              ),
            );
          } else if (hasSlots == 0) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      Icons.close,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Brak wolnych miejsc',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            );
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
    }
  }

  // Widget getAppointmentTile(index){

  // }

  final minTime = DateTime.now();

  Widget buildAppointments(List<Appointment> appointments) {
    hasSlots = 0;
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Card(
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
                  Icons.close,
                  color: Colors.red,
                ),
                title: Text(
                  'Brak wolnych miejsc',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
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
          // print(currentSlotFits);
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

              if (slot.breakTime) {
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
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (appointment.holiday) {
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (appointment.sunday) {
            return Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      'Niedziela',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
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
              child: Center(
                child: ListTile(
                  // leading: Icon(
                  //   Icons.access_time,
                  //   color: Theme.of(context).primaryColor,
                  // ),
                  title: Center(
                    child: Text(
                      'Od: ${DateFormat("yyyy-MM-ddTHH:mm:ss").parse(appointment.startTime, true).toLocal().toString().substring(11, 16)}',
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
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  subtitle: Center(
                    child: Text(
                      'Do: ${DateFormat("yyyy-MM-ddTHH:mm:ss").parse(appointment.endTime, true).add(
                            Duration(
                              minutes: 30 * (requiredSlots - 1),
                            ),
                          ).toLocal().toString().substring(11, 16)}',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onTap: () {
                    AppointmentData.id = appointment.id;
                    AppointmentData.startHour =
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(appointment.startTime, true)
                            .toLocal()
                            .toString()
                            .substring(11, 16);
                    AppointmentData.date = chosenDateString;
                    Navigator.pushNamed(context, '/confirmAppointment');
                  },
                ),
              ),
            );
          } else if (hasSlots == 0) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Card(
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
                      Icons.close,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Brak wolnych miejsc',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Wybierz datę',
          style: GoogleFonts.poppins(
            color: Theme.of(context).backgroundColor,
            fontSize: 28,
          ),
        ),
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
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
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
                  chosenDateString,
                  style: GoogleFonts.poppins(
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
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: minTime,
                    maxTime: minTime.add(
                      const Duration(days: 90),
                    ),
                    onChanged: (date) {},
                    onConfirm: (date) {
                      setState(() {
                        chosenDate = date;
                        chosenDateString =
                            DateFormat('yyyy-MM-dd').format(date);
                        AppointmentData.date = chosenDateString;
                        fetchAppointmentsData();
                      });
                    },
                    currentTime: chosenDate,
                    locale: LocaleType.pl,
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(right: 15),
              ),
            ],
          ),
          Expanded(
            flex: 30,
            child:
                // alignment: Alignment.center,
                getAppointmentsBody(),
            // child: FutureBuilder<List<Appointment>>(
            //   future: AppointmentsApi.getAppointments(
            //     context,
            //     chosenDateString,
            //   ),
            //   builder: (context, snapshot) {
            //     final appointments = snapshot.data;
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return const Center(
            //           child: CircularProgressIndicator(
            //             valueColor:
            //                 AlwaysStoppedAnimation<Color>(Colors.blue),
            //           ),
            //         );
            //       default:
            //         if (snapshot.hasError) {
            //           if (snapshot.error == 401) {
            //             regainAccessTokenFunction();
            //           }
            //           return Center(
            //             child: Text(
            //               'Wystąpił błąd przy pobieraniu danych. Spróbuj ponownie później.',
            //               style: GoogleFonts.poppins(
            //                 color: Theme.of(context).primaryColor,
            //               ),
            //             ),
            //           );
            //           // print(snapshot.error);
            //         } else {
            //           // print(snapshot.data);
            //           return buildAppointments(appointments!);
            //         }
            //     }
            //   },
            // ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 15)),
        ],
      ),
    );
  }
}
