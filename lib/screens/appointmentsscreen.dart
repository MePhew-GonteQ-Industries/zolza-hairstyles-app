import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:syncfusion_flutter_core/theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  final minTime = DateTime.now();
  // final maxTime = minTime.add(const Duration(days: 70));
  // var currentTime = DateTime.now().toString();
  // String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    // var mode = Brightness.light;
    // switch (isDarkMode) {
    //   case true:
    //     mode = Brightness.dark;
    //     break;
    //   default:
    //     mode = Brightness.light;
    // }
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
      // drawer: DrawerWidget().drawer(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              now,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColorDark,
                      elevation: 5,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: minTime,
                          maxTime: minTime.add(const Duration(days: 70)),
                          onChanged: (date) {
                        print('change $date');
                      }, onConfirm: (date) {
                        print('confirm $date');
                        Navigator.pushNamed(context, '/selectHour');
                        setState(() {
                          // now = date.toString().substring(0, 10);
                          now = DateFormat('dd-MM-yyyy').format(date);
                        });
                      }, currentTime: DateTime.now(), locale: LocaleType.pl);
                    },
                    child: const Text(
                      'Wybierz dzień',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            // SfCalendarTheme(
            //   data: SfCalendarThemeData(
            //     brightness: mode,
            //     timeTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     headerTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     todayTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     agendaDayTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     agendaDateTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     weekNumberTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     activeDatesTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     displayNameTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     viewHeaderDayTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //     viewHeaderDateTextStyle: TextStyle(
            //       color: Theme.of(context).primaryColor,
            //     ),
            //   ),
            //   child: SfCalendar(
            //     view: CalendarView.month,
            //     showDatePickerButton: true,
            //     monthViewSettings: const MonthViewSettings(
            //       showAgenda: true,
            //       dayFormat: 'EEE',
            //     ),
            //     allowedViews: const [
            //       CalendarView.day,
            //       CalendarView.month,
            //     ],
            //     timeSlotViewSettings: TimeSlotViewSettings(
            //       timeInterval: const Duration(
            //         minutes: 30,
            //       ),
            //       startHour: 6,
            //       endHour: 22,
            //       timeFormat: 'hh:mm',
            //       timeTextStyle: TextStyle(
            //         color: Theme.of(context).primaryColor,
            //       ),
            //     ),
            //   ),
            // ),
            Text(
              'Maksymalnie trzy miesiące do przodu',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
