import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  bool hourIsChoosen = false;
  @override
  void initState() {
    super.initState();
    hourIsChoosen = false;
  }

  buildSubmitButton() {
    if (hourIsChoosen) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 60,
          right: 60,
          top: 20,
          bottom: 20,
        ),
        child: SizedBox(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              primary: Theme.of(context).primaryColorDark,
              shadowColor: const Color(0xCC007AF3),
            ),
            onPressed: () async {},
            child: const Text(
              'Zapisz zmiany',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(
        width: double.infinity,
      );
    }
  }

  final minTime = DateTime.now();
  String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
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
                      maxTime: minTime.add(const Duration(days: 70)),
                      onChanged: (date) {}, onConfirm: (date) {
                    setState(() {
                      hourIsChoosen = true;
                      buildSubmitButton();
                    });
                    setState(() {
                      now = DateFormat('dd-MM-yyyy').format(date);
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.pl);
                },
              ),
              const Padding(padding: EdgeInsets.only(right: 15)),
            ],
          ),
          const Expanded(
            flex: 30,
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          Expanded(
            child: buildSubmitButton(),
            flex: 5,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 15)),
        ],
      ),
    );
  }
}
