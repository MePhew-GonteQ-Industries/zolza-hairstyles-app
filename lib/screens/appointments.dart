import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hairdressing_salon_app/helpers/appointment_data.dart';
import 'package:hairdressing_salon_app/helpers/login.dart';
import 'package:hairdressing_salon_app/helpers/user_data.dart';
import 'package:hairdressing_salon_app/helpers/user_secure_storage.dart';
import 'package:hairdressing_salon_app/widgets/user_not_verified_widget.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../constants/globals.dart';
import '../helpers/logout.dart';
import '../helpers/service_data.dart';
import '../widgets/alerts.dart';
import 'package:http/http.dart' as http;

var currentSlotFits = 0;
var requiredSlots = 0;
var slotsOccupied = 0;

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
  late List appointmentsData;
  bool isDataFetchedAppointmentsScreen = false;
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    currentDate = DateFormat("dd-MM-yyyy").format(now);
    chosenDate = now;
    chosenDateString = DateFormat('yyyy-MM-dd').format(chosenDate);
    currentSlotFits = 0;
    slotsOccupied = 0;
    requiredSlots = ServiceData.requiredSlots;
    fetchAppointmentsData();
    isDataFetchedAppointmentsScreen = false;
  }

  @override
  void dispose() {
    super.dispose();
    currentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    AppointmentData.date = currentDate;
  }

  retryFetchingAppointments() {
    Future.delayed(
      const Duration(seconds: 5),
    );
    fetchAppointmentsData();
  }

  showDateTimePicker() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: minTime,
      maxTime: minTime.add(
        const Duration(days: 30),
      ),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          chosenDate = date;
          chosenDateString = DateFormat('yyyy-MM-dd').format(date);
          AppointmentData.date = chosenDateString;
          isDataFetchedAppointmentsScreen = false;
          fetchAppointmentsData();
        });
      },
      currentTime: chosenDate,
      locale: LocaleType.pl,
    );
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
    if (response.statusCode == 200 && body != '[]') {
      setState(() {
        appointmentsData = body;
        isDataFetchedAppointmentsScreen = true;
      });
    } else {
      setState(() {
        appointmentsData = [];
        isDataFetchedAppointmentsScreen = false;
        retryFetchingAppointments();
      });
    }
  }

  regainAccessTokenFunction() async {
    // print('regaining access token');
    final refreshToken = await UserSecureStorage.getRefreshToken();
    Response regainAccessToken = await sendRefreshToken(refreshToken);
    // print(regainAccessToken);
    if (regainAccessToken.statusCode == 200) {
      // print('token regained');
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
    if (isDataFetchedAppointmentsScreen) {
      if (appointmentsData.isEmpty) {
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
        slotsOccupied = 0;
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: appointmentsData.length,
          itemBuilder: (context, index) {
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
              slotsOccupied++;
              if ((slotsOccupied == (appointmentsData.length - 1)) &&
                  appointment['occupied']) {
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
                );
              }
              return const SizedBox.shrink();
            } else if (currentSlotFits == requiredSlots) {
              return Card(
                color: Theme.of(context).backgroundColor,
                elevation: 8,
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
                    title: Center(
                      child: Text(
                        "Od: ${DateFormat('yyyy-MM-ddTHH:mm:ss').parse(appointment['start_time'], true).toString().substring(11, 16)}",
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
                            ).toString().substring(11, 16)}",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      if (DateFormat('EEEE').format(chosenDate) != 'Saturday') {
                        AppointmentData.id = appointment['id'];
                        AppointmentData.startHour =
                            DateFormat("yyyy-MM-ddTHH:mm:ss")
                                .parse(appointment['start_time'], true)
                                .toString()
                                .substring(11, 16);
                        AppointmentData.date = chosenDateString;
                        Navigator.pushNamed(context, '/confirmAppointment');
                      } else {
                        Alerts.alertSaturday(context);
                      }
                    },
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
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

  final minTime = DateTime.now();

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
          if (!UserData.verified) const UserNotVerified(),
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 15),
            ),
          ),
          Flexible(
            flex: 5,
            // fit: FlexFit.tight,
            child: Text(
              'Maksymalnie miesiąc do przodu!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // color: Theme.of(context).primaryColor,
                color: Theme.of(context).textTheme.bodyText2?.color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 15),
            ),
          ),
          // const Padding(padding: EdgeInsets.only(top: 15)),
          GestureDetector(
            onTap: (() => showDateTimePicker()),
            child: Row(
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
                Icon(
                  Icons.calendar_month_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 15),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 32,
            fit: FlexFit.tight,
            child: getAppointmentsBody(),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 15)),
        ],
      ),
    );
  }
}
